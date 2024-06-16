import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  static const Color primaryColor = Color.fromARGB(255, 8, 60, 123);
  static Color primaryBackgroundColor = primaryColor.withAlpha(128);

  final ThemeData _lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, onBackground: Colors.black),
    scaffoldBackgroundColor: Colors.white,
    shadowColor: const Color.fromARGB(100, 0, 0, 0),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: const RoundedRectangleBorder()))
  );

  final ThemeData _darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, onBackground: Colors.white),
    scaffoldBackgroundColor: Colors.black,
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: const RoundedRectangleBorder()))
  );

  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;

  late ThemeData _currentTheme;
  ThemeData get currentTheme => _currentTheme;
  
  ThemeProvider() {
    _currentTheme = _lightTheme; // Set the initial theme
  }

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
