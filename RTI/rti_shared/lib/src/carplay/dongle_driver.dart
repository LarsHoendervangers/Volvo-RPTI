import 'dart:async';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dart_buffer/dart_buffer.dart';
import 'package:rti_shared/src/carplay/carplay.dart';

import 'common.dart';
import 'usb_device_wrapper.dart';

class Dongle {
  final UsbDeviceWrapper _usbDevice;

  final Function(Message) _messageHandler;
  final Function({String? error}) _errorHandler;

  Timer? _heartBeat;

  Dongle(this._usbDevice, this._messageHandler, this._errorHandler);

  start() async {
    print('Dongle initializing');

    if (!_usbDevice.isOpened) {
      print('usbDevice not opened');
      return;
    }

    const config = DEFAULT_CONFIG;

    final initMessages = [
      SendNumber(config.dpi, FileAddress.DPI),
      SendOpen(config),
      SendBoolean(config.nightMode, FileAddress.NIGHT_MODE),
      SendNumber(config.hand.id, FileAddress.HAND_DRIVE_MODE),
      SendBoolean(false, FileAddress.CHARGE_MODE),
      SendString(config.boxName, FileAddress.BOX_NAME),
      SendBoxSettings(config, null),
      SendCommand(CommandMapping.wifiEnable),
      SendCommand(config.wifiType == '5ghz'
          ? CommandMapping.wifi5g
          : CommandMapping.wifi24g),
      SendCommand(
          config.micType == 'box' ? CommandMapping.boxMic : CommandMapping.mic),
      SendCommand(
        config.audioTransferMode
            ? CommandMapping.audioTransferOn
            : CommandMapping.audioTransferOff,
      ),
      if (config.androidWorkMode == true)
        SendBoolean(config.androidWorkMode!, FileAddress.ANDROID_WORK_MODE),
    ];

    for (final message in initMessages) {
      await send(message);
    }

    // Allow connection via WiFi.
    Future.delayed(const Duration(seconds: 1),
        () => send(SendCommand(CommandMapping.wifiConnect)));
    Timer? readTimer;
    readTimer = Timer.periodic(const Duration(milliseconds: 1), (timer) async {
      if (errorCount >= MAX_ERROR_COUNT) readTimer?.cancel();
      await _readLoop();
    });
    // _readLoop();
    // Future.doWhile(_readLoop());

    _heartBeat = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await send(HeartBeat());
    });
  }

  close() {
    _heartBeat?.cancel();
    _heartBeat = null;

    _usbDevice.close();
  }

  Future<bool> send(SendableMessage message) async {
    try {
      final data = message.serialise();

      if (EXTENDED_LOG) {
        print('[SEND] ${message.type.name} ${(message is SendCommand ? (message as SendCommand).value.name : "")}, length: ${data.length}, \ndata: ${hex.encode(data)}');
      } else {
        print('[SEND] ${message.type.name} ${(message is SendCommand ? (message as SendCommand).value.name : "")}');
      }

      final length = await _usbDevice.write(data);

      if (data.length == length) {
        return true;
      }
    } catch (e) {
      print(e);
    }

    return false;
  }

    final MAX_ERROR_COUNT = 5;
    var errorCount = 0;
  _readLoop() async {

    while (_usbDevice.isOpened || true) {
      // If we error out - stop loop, emit failure
      if (errorCount >= MAX_ERROR_COUNT) {
        print("Stopped reading, too many errors.");
        // close();
        // _errorHandler();
        return false;
      }

      try {
        final headerData = await _usbDevice.read(MessageHeader.dataLength, timeout: 250);
        print(headerData);
        if (headerData.isEmpty) {
          // continue;
          throw HeaderBuildError('Failed to read header data');
        }

        final header = MessageHeader.fromBuffer(
            BufferReader(headerData.buffer.asByteData()));

        ByteData? extraData;
        if (header.length > 0) {
          final extraDataRes = await _usbDevice.read(header.length, timeout: 250);

          if (extraDataRes.length < header.length) {
            print('Failed to read extra data');
            // return false;
          }

          extraData = extraDataRes.buffer.asByteData();
        }

        // if (extraData != null) {
        //   print(
        //       '[RECV] extraData length: ${extraData.lengthInBytes}, data: ${hex.encode(extraData.buffer.asUint8List())}');
        // }
        final message = header.toMessage(extraData);
        if (message != null) {
          String dataStr = hex.encode(extraData!.buffer.asUint8List());

          if (message is AudioData) {
            dataStr = 'AudioData';
          } else if (message is VideoData) {
            dataStr = 'VideoData';
          }

          if (EXTENDED_LOG) {
            print("[RECV] ${message.header.type.name} ${(message is Command ? message.value.name : "")}, header: ${hex.encode(headerData)},\nextraData length: ${extraData.lengthInBytes}, data: ${dataStr}");
          } else {
            print("[RECV] ${message.header.type.name} ${(message is Command ? message.value.name : "")}, length: ${extraData.lengthInBytes}");
          }

          // print(
          //     '[RECV] headerData length: ${header.length}, data: ${hex.encode(headerData)}');

          if (message is Opened) {
            await send(SendCommand(CommandMapping.wifiConnect));
          }

          try {
            _messageHandler(message);
          } catch (e) {
            print("Error handling message, ${e.toString()}");
          }
        }
      } catch (error) {
        bool isTimeout = error.toString().contains("TIMEOUT");
        if (!isTimeout) {
          if (error is HeaderBuildError) {
            print('Error parsing header for data ${error.message}');
          } else {
            print('Unexpected Error parsing header for data: $error');
          }
          errorCount++;
        }
      }

      return _usbDevice.isOpened;
    }
  }
}
