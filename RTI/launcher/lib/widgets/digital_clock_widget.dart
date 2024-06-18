import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';

class DigitalClock extends StatelessWidget {
  const DigitalClock({super.key});

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 20),
      builder: (context) {
        DateTime time = DateTime.now();
        return Text("${time.hour}:${time.minute.toString().padLeft(2, "0")}", textScaler: const TextScaler.linear(2));
      }
    );
  }
}