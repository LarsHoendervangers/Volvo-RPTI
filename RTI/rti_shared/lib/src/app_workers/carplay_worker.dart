import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:rti_shared/src/app_workers/carplay/carplay_dongle.dart';
import 'package:rti_shared/src/app_workers/carplay/carplay_message.dart';
import 'package:rti_shared/src/app_workers/carplay/carplay_send_messages.dart';

class CarplayWorker {
  // Dongle instance
  CarplayDongle? dongle;

  Timer? _heartBeatIntervalTimer;
  
  // Singleton
  CarplayWorker._();
  static final CarplayWorker _instance = CarplayWorker._();
  factory CarplayWorker() => _instance;

  void connectToDongle() async {
    if (!Platform.isLinux) return;
    dongle = CarplayDongle();
    await dongle!.setupDongle();
    startCarplay();
  }

  void startCarplay() async {
    if (!Platform.isLinux) return;
    List<SendableCarplayMessage> messages = [
      SendNumberCarplayMessage(dongle!.config.dpi, CarplayFileAddress.dpi),
      SendOpenCarplayMessage(dongle!.config),
      SendBoolCarplayMessage(dongle!.config.nightMode, CarplayFileAddress.nightMode),
      SendNumberCarplayMessage(dongle!.config.driverPosition.index, CarplayFileAddress.drivingPosition),
      SendBoolCarplayMessage(true, CarplayFileAddress.chargeMode),
      SendStringCarplayMessage(utf8.encode(dongle!.config.boxName), CarplayFileAddress.boxName.filePath),
      SendBoxSettingsCarplayMessage(DateTime.now(), dongle!.config),
      SendCommandCarplayMessage(CarplayCommand.wifiEnable),
      SendCommandCarplayMessage(dongle!.config.wifiType == WifiType.wifi_5ghz ? CarplayCommand.wifi5g : CarplayCommand.wifi24g),
      SendCommandCarplayMessage(dongle!.config.micType == MicType.box ? CarplayCommand.boxMic : CarplayCommand.mic),
      SendCommandCarplayMessage(dongle!.config.audioTransferMode ? CarplayCommand.audioTransferOn : CarplayCommand.audioTransferOff)
    ];

    for (SendableCarplayMessage message in messages) {
      try {
        int result = await dongle!.send(message);
        if (result == -1) {
          print("Failed to send one or more start commands to carplay dongle!");
          return;
        }
      } catch (err) {
        print("Error occured while starting Carplay: $err");
      }
    }

    print("Sent start commands to dongle.");
    
    // _read();

    _heartBeatIntervalTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      try {
        await dongle!.send(SendHeartBeatCarplayMessage()); 
      } catch(err) {
        _heartBeatIntervalTimer?.cancel();
      }
    });

    Future.doWhile(_read);
  }

  Future<bool> _read() async {
    const int maxErrors = 5;
    int errorCount = 0;
    int lastHeartBeatTime = 0;

    // while (dongle!.isOpened()) {
      if (dongle == null) {
        print("Reading has stopped, because no dongle was found!");
        dispose();
        return false;
      }
      if (errorCount >= maxErrors) {
        print("Reading has stopped, because an error count of 5 or more has reached.");
        dispose();
        return false;
      }

      // Send heartbeat
      // DateTime currentTime = DateTime.now();
      // if (currentTime.millisecondsSinceEpoch - lastHeartBeatTime >= 2000) {
      //   lastHeartBeatTime = currentTime.millisecondsSinceEpoch;
      //   await dongle!.send(SendHeartBeatCarplayMessage());
      // }

      // Read data
      List<int> result = List.empty(growable: true);
      try {
        result = await dongle!.read(CarplayMessageHeader.headerLength, 2000);
      } catch (err) {
        if (!err.toString().contains("TIMEOUT")) errorCount++;
      }
      if (result.isEmpty) return true;
      print("Read: $result");
      // A message was read succesfully.
      CarplayMessageHeader header = CarplayMessageHeader.fromBuffer(Uint8List.fromList(result));

      if (header.length > 0) {
        Uint8List extraData = Uint8List.fromList(await dongle!.read(header.length, 2000));

        if (extraData.length < header.length) {
          print("Failed to read extra data!");
          return true;
        }
      }
    // }
    return true;
  }

  void stopCarplay() {
    if (!Platform.isLinux) return;

  }

  void dispose() {
    _heartBeatIntervalTimer?.cancel();
    
    if (!Platform.isLinux) return;
    dongle?.dispose();
    dongle = null;
  }
}