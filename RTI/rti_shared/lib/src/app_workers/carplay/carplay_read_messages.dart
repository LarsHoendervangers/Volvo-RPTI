import 'package:rti_shared/src/app_workers/carplay/carplay_message.dart';

class ReadOpenCarplayMessage extends CarplayMessage {
  final int width;
  final int height;
  final int fps;
  final int format;
  final int packetMax;
  final int iBox;
  final int phoneMode;

  ReadOpenCarplayMessage(this.width, this.height, this.fps, this.format, this.packetMax, this.iBox, this.phoneMode, super.header);
}