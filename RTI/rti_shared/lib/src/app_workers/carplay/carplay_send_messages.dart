import 'dart:convert';
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:rti_shared/src/app_workers/carplay/carplay_dongle.dart';
import 'package:rti_shared/src/app_workers/carplay/carplay_message.dart';

enum CarplayFileAddress {
  dpi("/tmp/screen_dpi"),
  nightMode("/tmp/night_mode"),
  drivingPosition("/tmp/hand_drive_mode"),
  chargeMode("/tmp/charge_mode"),
  boxName("/etc/box_name"),
  oemIcon("/etc/oem_icon.png"),
  airplayConfig("/etc/airplay.conf"),
  icon120("/etc/icon_120x120.png"),
  icon180("/etc/icon_180x180.png"),
  icon250("/etc/icon_256x256.png"),
  androidWorkmode("/etc/android_work_mode");

  final String filePath;
  const CarplayFileAddress(this.filePath);
}

class SendFileCarplayMessage extends SendableCarplayMessage {
  Uint8List content;
  String fileName;
  SendFileCarplayMessage(this.content, this.fileName) : super(CarplayMessageType.sendFile);

  Uint8List _getLength(Uint8List name) {
    ByteDataWriter writer = ByteDataWriter(bufferLength: 4, endian: Endian.little);
    writer.writeUint32(name.length);
    return writer.toBytes();
  }

  @override
  Uint8List toBytes() {
    // ignore: unnecessary_string_escapes
    Uint8List newFileName = Uint8List.fromList([...ascii.encode(fileName), 0]);
    Uint8List nameLength = _getLength(newFileName);
    Uint8List contentLength = _getLength(content);
    return Uint8List.fromList([...newFileName, ...nameLength, ...contentLength]);
    // ByteDataWriter writer = ByteDataWriter(bufferLength: newFileName.length + nameLength.length + contentLength.length, endian: Endian.little);
    // writer.write(newFileName);
    // writer.write(nameLength);
    // writer.write(contentLength);
    // return writer.toBytes();
    // Uint8List data = Uint8List(newFileName.length + nameLength.length + contentLength.length);
    // int startPos = 0;
    // int endPos = newFileName.length;
    // data.setRange(startPos, endPos, newFileName);
    // startPos += newFileName.length;
    // endPos = startPos + nameLength.length;
    // data.setRange(startPos, endPos, nameLength);
    // startPos += nameLength.length;
    // endPos = startPos + contentLength.length;
    // data.setRange(startPos, endPos, contentLength);
    // return data;
  }
}

class SendNumberCarplayMessage extends SendFileCarplayMessage {
  final int number;
  final CarplayFileAddress address;

  SendNumberCarplayMessage(this.number, this.address) : super(Uint8List(4), address.filePath) {
    ByteDataWriter writer = ByteDataWriter(bufferLength: 4, endian: Endian.little);
    writer.writeUint32(number);
    super.content = writer.toBytes();
  }
}

class SendBoolCarplayMessage extends SendNumberCarplayMessage {
  SendBoolCarplayMessage(bool content, CarplayFileAddress address) : super(content ? 1 : 0, address);
}

class SendStringCarplayMessage extends SendFileCarplayMessage {
  SendStringCarplayMessage(super.content, super.fileName) {
    assert (super.content.length < 16);
  }
}

class SendBoxSettingsCarplayMessage extends SendableCarplayMessage {
  final DateTime time;
  final DongleConfig config;

  SendBoxSettingsCarplayMessage(this.time, this.config) : super(CarplayMessageType.boxSettings);

  @override
  Uint8List toBytes() {
    Map<String, dynamic> data = {
      'mediaDelay': config.mediaDelay,
      'syncTime': time.millisecondsSinceEpoch,
      'androidAutoSizeW': config.width,
      'androidAutoSizeH': config.height
    };
    String json = JsonEncoder().convert(data);
    return ascii.encode(json).buffer.asUint8List();
  }  
}

class SendCommandCarplayMessage extends SendableCarplayMessage {
  CarplayCommand cmd;

  SendCommandCarplayMessage(this.cmd) : super(CarplayMessageType.command);

  @override
  Uint8List toBytes() {
    ByteDataWriter writer = ByteDataWriter(bufferLength: 4, endian: Endian.little);
    writer.writeUint32(cmd.value);
    return writer.toBytes();
    // Uint8List data = Uint8List(4);
    // data[0] = cmd.value;
    // return data;
  }
}

class SendHeartBeatCarplayMessage extends SendableCarplayMessage {
  SendHeartBeatCarplayMessage() : super(CarplayMessageType.heartBeat);
}

class SendOpenCarplayMessage extends SendableCarplayMessage {
  final DongleConfig config;

  SendOpenCarplayMessage(this.config) : super(CarplayMessageType.open);

  @override
  Uint8List toBytes() {
    ByteDataWriter writer = ByteDataWriter(bufferLength: 28, endian: Endian.little);
    writer.writeUint32(config.width);
    writer.writeUint32(config.height);
    writer.writeUint32(config.fps);
    writer.writeUint32(config.format);
    writer.writeUint32(config.packetMax);
    writer.writeUint32(config.iBoxVersion);
    writer.writeUint32(config.phoneWorkMode);
    return writer.toBytes();
    // Uint8List bytes = Uint8List(224);
    // bytes[0] = config.width;
    // bytes[32] = config.height;
    // bytes[64] = config.fps;
    // bytes[96] = config.format;
    // bytes[128] = config.packetMax;
    // bytes[160] = config.iBoxVersion;
    // bytes[192] = config.phoneWorkMode;
    // return bytes;
  }
}