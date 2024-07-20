import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:rti_shared/rti_shared.dart';

import 'dongle_driver.dart';
import 'usb_device_wrapper.dart';
import 'common.dart';

// ignore: constant_identifier_names
const USB_WAIT_PERIOD_MS = 3000;

const EXTENDED_LOG = false;

class Carplay {
  Timer? _pairTimeout;
  Timer? _frameInterval;

  final DongleConfig _config;

  Dongle? _dongleDriver;

  final void Function(Message message) _messageHandler;

  Carplay(this._config, this._messageHandler) {
    UsbManagerWrapper.init();
  }

  Future<UsbDeviceWrapper> _findDevice() async {
    UsbDeviceWrapper? device;

    while (device == null) {
      final deviceList = await UsbManagerWrapper.lookupForUsbDevice([
        KnownDevice(0x1314, 0x1520),
        KnownDevice(0x1314, 0x1521)
      ]);
      device = deviceList.firstOrNull;

      if (device == null) {
        print('No device found, retrying');
        await Future.delayed(const Duration(milliseconds: USB_WAIT_PERIOD_MS));
      }
    }

    return device;
  }

  start() async {
    // Find device to "reset" first
    // var device = await _findDevice();

    // await device.open();
    // await device.reset();
    // await device.close();
    // Resetting the device causes an unplug event in node-usb
    // so subsequent writes fail with LIBUSB_ERROR_NO_DEVICE
    // or LIBUSB_TRANSFER_ERROR

    // print('Reset device, finding again...');
    // await Future.delayed(const Duration(milliseconds: USB_WAIT_PERIOD_MS));
    // ^ Device disappears after reset for 1-3 seconds

    var device = await _findDevice();
    print('found & opening');
    _dongleDriver = Dongle(device, _handleDongleMessage, _handleDongleError);
    // Terminal().runCmd("gst-launch-1.0 -v filesrc location = /tmp/carplay_video.mp4 ! decodebin ! x264enc ! rtph264pay ! udpsink host=localhost port=9001", []);

    try {
      await device.open();

      await _dongleDriver?.start();

      // _pairTimeout = Timer(const Duration(seconds: 15), () {
      //   _dongleDriver?.send(SendCommand(CommandMapping.wifiPair));
      // });
    } catch (e) {
      print(e.toString());

      print('carplay not initialised, retrying in 2s');

      await Future.delayed(const Duration(seconds: 2), start);
    }
  }

  stop() async {
    try {
      _clearPairTimeout();
      _clearFrameInterval();
      await _dongleDriver?.close();
    } catch (err) {
      print(err.toString());
    }
  }

  sendKey(CommandMapping action) {
    _dongleDriver?.send(SendCommand(action));
  }

  sendTouch(TouchAction type, int x, int y) {
    _dongleDriver?.send(SendTouch(type, x, y));
  }

  _handleDongleMessage(Message message) {
    if (message is Plugged) {
      _clearPairTimeout();
      _clearFrameInterval();

      final phoneTypeConfig = _config.phoneConfig[message.phoneType];
      final interval = phoneTypeConfig?["frameInterval"];
      if (interval != null) {
        _frameInterval = Timer.periodic(Duration(milliseconds: interval), (timer) async {
          _messageHandler(KeyFrame());
          await _dongleDriver?.send(SendCommand(CommandMapping.frame));
        });
      }

      _messageHandler(message);
    } else if (message is Unplugged) {
      _messageHandler(message);
    } else if (message is VideoData) {
      _clearPairTimeout();
      // print("Frame duration: ${(ByteDataReader(endian: Endian.big)..add(message.data.asUint8List())).readUint32()}");
      _messageHandler(message);
      // writeVideoStreamToSocket(message.data.asUint8List());
    } else if (message is AudioData) {
      _clearPairTimeout();
      _messageHandler(message);
    } else if (message is MediaData) {
      _clearPairTimeout();
      _messageHandler(message);
    } else if (message is Command) {
      _messageHandler(message);
    }

    // Trigger internal event logic
    if (message is AudioData && message.command != null) {
      switch (message.command) {
        case AudioCommand.AudioSiriStart:
        case AudioCommand.AudioPhonecallStart:
//            mic.start()
          break;
        case AudioCommand.AudioSiriStop:
        case AudioCommand.AudioPhonecallStop:
//            mic.stop()
          break;

        default:
          break;
      }
    }
  }

  _handleDongleError({String? error}) async {
    await stop();
    await start();
  }

  _clearPairTimeout() {
    _pairTimeout?.cancel();
    _pairTimeout = null;
  }

  _clearFrameInterval() {
    if (_frameInterval != null) {
      _frameInterval?.cancel();
      _frameInterval = null;
    }
  }
}
