// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:rti_shared/rti_shared.dart';

// class CarplayPlayer extends StatefulWidget {
//   const CarplayPlayer({super.key});
  
//   @override
//   State<StatefulWidget> createState() => _CarplayPlayerState();
// }

// class _CarplayPlayerState extends State<CarplayPlayer> {
//   Process? _ffmpeg;
//   final File _rawFile = File("/tmp/video.h264");
//   final File _imageFile = File("/tmp/output.png");
//   Image? _image;
//   bool videoReady = false;
//   Carplay? carplay;

//   @override
//   void initState() {
//     super.initState();
//     // Carplay
//     if (carplay == null) {
//       carplay = Carplay(DEFAULT_CONFIG, _handleMessage);
//       carplay!.start();
//     }

//     // TESTING ONLY
//     _rawFile.writeAsBytesSync([], flush: true);
//     _imageFile.writeAsBytesSync([], flush: true);

//     FlutterError.onError = (FlutterErrorDetails details) {
//       if (details.library == 'image resource service') {
//         return;
//       }
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     ImageCache cache = ImageCache();
//     cache.clear();
//     cache.clearLiveImages();
//     print("Loading new image");
//     // if (!_imageFile.existsSync() || _imageFile.lengthSync() < 5) return Text("No video data yet...");
//     if (_image == null) return Text("Waiting for data");
//     return Center(
//       child: _image
//     );
//   }

//   // int framesReceivedCount = 0;

//   void _handleMessage(Message message) async {
//     if (message is KeyFrame) {
//       print("New keyframe started");
//     } else if (message is VideoData) {
//       print("Received video data");
//       if (_ffmpeg == null) {
//         print("Creating new ffmpeg instance");
//         // _ffmpeg = await Terminal().start("/usr/bin/ffmpeg", '-hide_banner -loglevel error -y -f h264 -i pipe:0 -vf select=gte(n\\,n-1) -vsync vfr -f image2 -update 1 /tmp/output.png'.split(" "));
//         // _ffmpeg = await Terminal().start("/usr/bin/ffmpeg", '-hide_banner -loglevel error -probesize 20000 -y -f h264 -i - -vf select=gte(n\,n-1) -vframes 1 -c:v png -f image2pipe -'.split(" "));
//         _ffmpeg = await Terminal().start("/usr/bin/ffmpeg", '-hide_banner -loglevel error -fflags discardcorrupt -probesize 32 -r 1 -f h264 -i - -update 1 -f image2pipe -vcodec png -'.split(" "));
//         _ffmpeg!.stderr.listen((event) => print("STDERR: ${utf8.decode(event)}"));
//         _ffmpeg!.stdout.listen((event) async {
//           // print("STDOUT: ${utf8.decode(event)}"); 
//           print("New image received from ffmpeg");
//           Uint8List imageData = Uint8List.fromList(event);
//           if (await isImageValid(imageData)) {
//             setState(() {
//               _image = Image.memory(imageData, gaplessPlayback: true);
//             });
//           }
//         });
//       }
//       _ffmpeg?.stdin.add(message.data.asUint8List());
//       // _rawFile.writeAsBytesSync(message.data.asUint8List(), mode: FileMode.append, flush: true);
//       // Terminal().runCmd("/usr/bin/ffmpeg", "-hide_banner -loglevel error -sseof -1 -y -i /tmp/video.h264 -update 1 -q:v 1 -f image2 /tmp/output.png".split(" "));
//       // setState(() {
//       //   videoReady = !videoReady;
//       //   _image = Image.file(_imageFile);
//       // });
//     } else if (message is Plugged) {
//       print("Phone connected to dongle!");
//     } else if (message is Unplugged) {
//       print("Phone disconnected from dongle!");
//     }
//   }

//   Future<bool> isImageValid(List<int> rawList) async {
//   final uInt8List =
//       rawList is Uint8List ? rawList : Uint8List.fromList(rawList);

//   try {
//     final codec = await instantiateImageCodec(uInt8List, targetWidth: 32);
//     final frameInfo = await codec.getNextFrame();
//     return frameInfo.image.width > 0;
//   } catch (e) {
//     return false;
//   }
// }

//   @override
//   void dispose() {
//     super.dispose();
//     carplay?.stop();
//     _ffmpeg?.kill();
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:launcher/widgets/apps/bitmap_painter.dart';
import 'package:rti_shared/rti_shared.dart';

class CarplayPlayer extends StatefulWidget {
  const CarplayPlayer({super.key});
  
  @override
  State<StatefulWidget> createState() => _CarplayPlayerState();
}

class _CarplayPlayerState extends State<CarplayPlayer> {
  Process? _ffmpeg;
  ui.Image? _image;
  Carplay? carplay;

  @override
  void initState() {
    super.initState();
    // Carplay
    if (carplay == null) {
      carplay = Carplay(DEFAULT_CONFIG, _handleMessage);
      carplay!.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _image == null
            ? CircularProgressIndicator()
            : CustomPaint(
        painter: BitmapPainter(_image!),
        child: Container(
          width: 400,
          height: 200,
        ),
      )
    );
  }

  void _handleMessage(Message message) async {
    if (message is KeyFrame) {
      print("New keyframe started");
    } else if (message is VideoData) {
      print("Received video data");
      if (_ffmpeg == null) {
        print("Creating new ffmpeg instance");_ffmpeg = await Terminal().start("/usr/bin/ffmpeg", '-hide_banner -loglevel error -r 60 -f h264 -i - -f image2pipe -vcodec bmp -threads 4 -'.split(" "));
        _ffmpeg!.stderr.listen((event) => print("STDERR: ${utf8.decode(event)}"));
        _ffmpeg!.stdout.listen((event) async {
          print("New image received from ffmpeg");
          Uint8List imageData = Uint8List.fromList(event);
          if (await isImageValid(imageData)) {
            final ui.Codec codec = await ui.instantiateImageCodec(imageData);
            ui.FrameInfo frameInfo = await codec.getNextFrame();
            setState(() {
              _image = frameInfo.image;
            });
          }
        });
      }
      _ffmpeg?.stdin.add(message.data.asUint8List());
    } else if (message is Plugged) {
      print("Phone connected to dongle!");
    } else if (message is Unplugged) {
      print("Phone disconnected from dongle!");
    }
  }

  Future<bool> isImageValid(List<int> rawList) async {
  final uInt8List =
      rawList is Uint8List ? rawList : Uint8List.fromList(rawList);

  try {
    final codec = await instantiateImageCodec(uInt8List, targetWidth: 32);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image.width > 0;
  } catch (e) {
    return false;
  }
}

  @override
  void dispose() {
    super.dispose();
    carplay?.stop();
    _ffmpeg?.kill();
  }
}