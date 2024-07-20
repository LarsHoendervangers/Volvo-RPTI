import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BitmapPainter extends CustomPainter {
  final ui.Image image;

  BitmapPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    // Scale the image to fit the canvas size
    final Rect src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final Rect dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
