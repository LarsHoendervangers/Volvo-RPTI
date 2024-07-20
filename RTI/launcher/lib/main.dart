import 'dart:io';

// import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart' hide Notification, NotificationListener;
import 'package:launcher/app_selector.dart';
import 'package:launcher/theme_provider.dart';
import 'package:launcher/widgets/apps/carplay_player.dart';
import 'package:launcher/widgets/maps/mapview.dart';
import 'package:launcher/widgets/notification_widget.dart';
import 'package:provider/provider.dart';

import 'package:rti_shared/rti_shared.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutterpi_gstreamer_video_player/flutterpi_gstreamer_video_player.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  FlutterpiVideoPlayer.registerWith();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: HomeScreen()
      )
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin implements NotificationListener {
  static const Curve curve = Curves.easeOut;
  late AnimationController _controller;
  // ignore: avoid_init_to_null
  late Notification? activeNotification = null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 499),
    );
  }
  
  @override
  void onNotificationPushed(Notification notification) {
    setState(() {
      activeNotification = notification;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ServiceProvider().notificationService.subscribe(this);
      showNotification(activeNotification);
    });

    return Center(child: CarplayPlayer());
    // return AppSelector();
    // return const MapView();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    ServiceProvider().notificationService.unsubscribe(this);
  }

  void showNotification(Notification? notification) {
    if (notification == null) return;
    
    _controller.forward();
    Future.delayed(Duration(milliseconds: notification.visibleDuration), () => _controller.reverse());
    
    OverlayEntry entry = OverlayEntry(builder: (context) => Positioned(
      top: 0,
      left: 0,
      child: AnimatedBuilder(
        builder: (context, child) {
          final double animationValue = curve.transform(_controller.value);
          return Opacity(
            opacity: animationValue,
            child: FractionalTranslation(
              translation: Offset(0, -(1 - animationValue)),
              child: child,
            )
          );
        },
        animation: _controller,
        child: Material(
          child: NotificationWidget(notification),
        ),
      )
    )
    );
    Overlay.of(context).insert(entry);

    Future.delayed(Duration(milliseconds: notification.visibleDuration + 500), () {
      entry.remove();
    });
  }
}
