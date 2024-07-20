import 'dart:typed_data';

import 'package:quick_usb/quick_usb.dart';

class KnownDevice {
  int vendorId;
  int productId;

  KnownDevice(this.vendorId, this.productId);
}

class UsbManagerWrapper {
  static init() async {
    QuickUsbLinux.registerWith();

    print('USB Manager init');
    if (!await QuickUsb.init()) {
      print("Failed to init QuickUSB");
    }
  }

  static close() async {
    print('USB Manager close');
    await QuickUsb.exit();
  }

  static Future<List<UsbDeviceWrapper>> lookupForUsbDevice(List<KnownDevice> knownDevices) async {
    var devices = await QuickUsb.getDeviceList();
    List<UsbDeviceWrapper> filtered = [];
    for (UsbDevice device in devices) {
      for (KnownDevice knownDevice in knownDevices) {
        if (device.vendorId == knownDevice.vendorId && device.productId == knownDevice.productId) {
          filtered.add(UsbDeviceWrapper(device));
        }
      }
    }
    return filtered;
  }
}

class UsbDeviceWrapper {
  bool _isOpened = false;
  bool get isOpened => _isOpened;

  final UsbDevice _usbDevice;

  UsbEndpoint? _endpointIn;
  UsbEndpoint? _endpointOut;

  UsbDeviceWrapper(this._usbDevice);

  open() async {
    var success = await QuickUsb.openDevice(_usbDevice);
    print('USB Device open >>> $success');

    var conf = await QuickUsb.getConfiguration(0);
    print('USB Device configuration');

    await QuickUsb.setConfiguration(conf);
    print('USB Device set configuration');

    var interface = conf.interfaces.first;
    success = await QuickUsb.claimInterface(interface);
    print('USB Device claimInterface');

    _endpointIn = interface.endpoints
        .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_IN);

    _endpointOut = interface.endpoints
        .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_OUT);

    _isOpened = true;
  }

  close() async {
    await QuickUsb.closeDevice();
    _isOpened = false;
  }

  reset() async {
    // await QuickUsb.resetDevice(_usbDevice);
  }

  Future<Uint8List> read(int maxLength, {int timeout = 30000}) {
    if (!isOpened) throw "UsbDevice not opened";
    if (_endpointIn == null) throw "UsbDevice endpointIn is null";

    return QuickUsb.bulkTransferIn(_endpointIn!, maxLength, timeout: timeout);
  }

  Future<int> write(Uint8List data) {
    if (!isOpened) throw "UsbDevice not opened";
    if (_endpointOut == null) throw "UsbDevice endpointOut is null";

    return QuickUsb.bulkTransferOut(_endpointOut!, data);
  }
}
