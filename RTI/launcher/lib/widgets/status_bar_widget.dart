import 'package:flutter/material.dart';
import 'package:launcher/widgets/digital_clock_widget.dart';

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatefulWidget> createState() => StatusBarState();
}

class StatusBarState extends State<StatusBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // border: Border(bottom: BorderSide(color: Colors.black, width: 3))
      ),
      child: const Center(
        child: DigitalClock(),
      ),
    );
  }
}