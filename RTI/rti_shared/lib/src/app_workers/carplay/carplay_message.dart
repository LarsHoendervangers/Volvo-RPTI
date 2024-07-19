import 'dart:typed_data';

import 'package:buffer/buffer.dart';

abstract class CarplayMessage {
  final CarplayMessageHeader header;

  CarplayMessage(this.header);
}

class CarplayMessageHeader {
  static final int magic = 0x55AA55AA;
  static final int headerLength = 16;
  final int length;
  final CarplayMessageType type;

  CarplayMessageHeader(this.length, this.type);

  static CarplayMessageHeader fromBuffer(Uint8List data) {
    ByteDataReader reader = ByteDataReader(endian: Endian.little);
    reader.add(data);
    if (data.length != 16) {
      throw Exception(
          'Invalid buffer size - Expecting 16, got ${data.length}');
    }
    final magic = reader.readUint32();
    if (magic != CarplayMessageHeader.magic) {
      throw Exception('Invalid magic number, received $magic');
    }
    final length = reader.readUint32();
    final typeInt = reader.readUint32();
    final msgType = CarplayMessageType.fromId(typeInt);

    if (msgType == CarplayMessageType.unknown) {
      print("Unknown message type: $typeInt");
    } else {
      final typeCheck = reader.readUint32();
      if (typeCheck != ((msgType.id ^ -1) & 0xffffffff) >>> 0) {
        throw Exception('Invalid type check, received $typeCheck');
      }
    }

    return CarplayMessageHeader(length, msgType);
  }

  static Uint8List asBuffer(CarplayMessageType type, int length) {
    ByteDataWriter writer = ByteDataWriter(bufferLength: 16);
    writer.writeUint32(length);
    writer.writeUint32(type.id);
    writer.writeUint32(((type.id ^ -1) & 0xFFFFFFFF) >>> 0);
    writer.writeUint32(CarplayMessageHeader.magic);
    return writer.toBytes();
  }
}

abstract class SendableCarplayMessage {
  final CarplayMessageType type;
  SendableCarplayMessage(this.type);

  Uint8List toBytes() {
    return CarplayMessageHeader.asBuffer(type, 0);
  }
}

enum CarplayMessageType {
  unknown(-1),
  open(0x01),
  command(0x08),
  boxSettings(0x19),
  sendFile(0x99),
  heartBeat(0xAA);

  final int id;
  const CarplayMessageType(this.id);

  factory CarplayMessageType.fromId(int id) {
    return CarplayMessageType.values.firstWhere((element) => element.id == id, orElse: () => unknown);
  }
}

enum CarplayCommand {
  invalid(0),
  startRecordAudio(1),
  stopRecordAudio(2),
  requestHostUi(3),
  siri(5),
  mic(7),
  boxMic(15),
  enableNightMode(16),
  disableNightMode(17),
  wifi24g(24),
  wifi5g(25),
  left(100),
  right(101),
  frame(12),
  audioTransferOn(22),
  audioTransferOff(23),
  selectDown(104),
  selectUp(105),
  back(106),
  down(114),
  home(200),
  play(201),
  pause(202),
  next(204),
  prev(205),
  requestVideoFocus(500),
  releaseVideoFocus(401),
  wifiEnable(1000),
  autoConnectEnable(1001),
  wifiConnect(1002),
  scanningDevice(1003),
  deviceFound(1004),
  deviceNotFound(1005),
  connectDeviceFailed(1006),
  btConnected(1007),
  btDisconnected(1008),
  wifiConnected(1009),
  wifiDisconnected(1010),
  btPairStart(1011),
  wifiPair(1012);

  final int value;
  const CarplayCommand(this.value);

  factory CarplayCommand.fromId(int id) {
    return CarplayCommand.values.firstWhere((element) => element.value == id, orElse: () => invalid);
  }
}