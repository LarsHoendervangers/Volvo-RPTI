import 'dart:io';

import 'package:quick_usb/quick_usb.dart';
import 'package:rti_shared/src/app_workers/carplay/carplay_message.dart';

class CarplayDongle {
  CarplayDongle._();
  static final CarplayDongle _instance = CarplayDongle._();
  factory CarplayDongle() => _instance;
  static final List<_KnownDongle> _knownDongles = [
    _KnownDongle(productId: 0x1520, vendorId: 0x1314),
    _KnownDongle(productId: 0x1521, vendorId: 0x1314),
  ];

  UsbDevice? _dongle;
  UsbInterface? _interface;
  UsbEndpoint? _inEndpoint;
  UsbEndpoint? _outEndpoint;

  DongleConfig config = defaultCarplayDongleConfig;

  // Connects to the dongle.
  Future<void> setupDongle() async {
    if (!Platform.isLinux) {
      print("Not using Linux, disabling Carplay.");
      return;
    }
    print("Searching for compatible Carplay dongle...");
    QuickUsbLinux.registerWith();
    if (!await QuickUsb.init()) {
      print("Failed to init QuickUsb");
      return;
    }

    // Get all connected USB devices.
    for (UsbDevice device in await QuickUsb.getDeviceList()) {
      // Search for device ids in _knownDongles
      for (_KnownDongle dongle in _knownDongles) {
        if (device.productId == dongle.productId && device.vendorId == dongle.vendorId) {
          _dongle = device;
          // Break from loop because a dongle was found.
          break;
        }
      }
    }
    if (_dongle == null) {
      print("Dongle not found.");
      return;
    }

    print("Dongle found!");
    if (!await QuickUsb.openDevice(_dongle!)) {
      print("Failed to open dongle.");
      return;
    }
    print("Opened dongle.");
    // await QuickUsb.setAutoDetachKernelDriver(true);
    UsbConfiguration config = await QuickUsb.getConfiguration(0);
    print(config);
    _interface = config.interfaces[0];
    if (_interface == null) return;
    _inEndpoint = _interface!.endpoints.where((ep) => ep.direction == UsbEndpoint.DIRECTION_IN).first;
    if (_inEndpoint == null) {
      print("No IN endpoint!");
      return;
    }
    _outEndpoint = _interface!.endpoints.where((ep) => ep.direction == UsbEndpoint.DIRECTION_OUT).first;
    if (_outEndpoint == null) {
      print("No OUT endpoint!");
      return;
    }
  }

  Future<int> send(SendableCarplayMessage message) async {
    if (_dongle == null) return -1;

    try {
      print("Send: ${message.type}, length: ${message.toBytes().length}");
      return await QuickUsb.bulkTransferOut(_outEndpoint!, message.toBytes());
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<List<int>> read(int length, int timeout) async {
    if (_inEndpoint == null) return List.empty();
    try {
      return await QuickUsb.bulkTransferIn(_inEndpoint!, length, timeout: timeout);
    } catch (err) {
      print(err);
      throw Exception(err);
    }
  }

  bool isOpened() {
    return _dongle != null;
  }

  Future<void> dispose() async {
    if (_dongle == null) return;
    if (_interface != null) await QuickUsb.detachKernelDriver(_interface!);
    await QuickUsb.closeDevice();
    _dongle = null;
    _inEndpoint = null;
    _outEndpoint = null;
    _interface = null;
  }
}

class _KnownDongle {
  int productId;
  int vendorId;

  _KnownDongle({required this.productId, required this.vendorId});
}

enum DriverPosition {
  leftHandDrive, rightHandDrive
}

enum WifiType {
  wifi_2_4ghz, wifi_5ghz
}

enum MicType {
  box, os
}

class PhoneConfig {
  int? frameInterval;

  PhoneConfig(this.frameInterval);
}

class DongleConfig {
  bool? androidWorkMode;
  int width;
  int height;
  int fps;
  int dpi;
  int format;
  int iBoxVersion;
  int packetMax;
  int phoneWorkMode;
  bool nightMode;
  String boxName;
  DriverPosition driverPosition;
  int mediaDelay;
  bool audioTransferMode;
  WifiType wifiType;
  MicType micType;

  DongleConfig(this.androidWorkMode, this.width, this.height, this.fps, this.dpi, this.format, this.iBoxVersion, 
    this.packetMax, this.phoneWorkMode, this.nightMode, this.boxName, this.driverPosition, this.mediaDelay, this.audioTransferMode, this.wifiType, this.micType);
}

DongleConfig defaultCarplayDongleConfig = DongleConfig(null, 800, 640, 20, 160, 5, 2, 49162, 2, false, 'flutterPlay', DriverPosition.leftHandDrive, 300, false, WifiType.wifi_5ghz, MicType.os);