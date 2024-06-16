import 'dart:ui';

import 'package:flutter/material.dart' hide Notification;
import 'package:rti_shared/rti_shared.dart';

class NotificationWidget extends StatefulWidget {
  final Notification notification;
  const NotificationWidget(this.notification, {super.key});

  @override
  State<StatefulWidget> createState() => NotificationWidgetState();
}

class NotificationWidgetState extends State<NotificationWidget> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(125, 206, 206, 206),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: IntrinsicWidth(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.notification.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                    Text(widget.notification.description, style: const TextStyle(fontSize: 25))
                  ]
                )
              )
              )
            )
          )
        )
      // )
    );
  }
}