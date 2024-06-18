import 'package:flutter/material.dart';
import 'package:launcher/widgets/status_bar_widget.dart';

class AppSelector extends StatefulWidget {
  const AppSelector({super.key});

  @override
  State<StatefulWidget> createState() => AppSelectorState();
}

class AppSelectorState extends State<AppSelector> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatusBar(),
        Center(child: Text("TODO: Create horizontal app list")),
        Center(child: Text("TODO: Create app page indicator"))
      ]
    );
  }
}