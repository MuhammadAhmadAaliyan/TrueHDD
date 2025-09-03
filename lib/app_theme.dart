import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFE0E0E0),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFFE0E0E0),
      textStyle: TextStyle(color: Colors.black),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2C2C2C),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF2C2C2C),
      textStyle: TextStyle(color: Colors.white),
    ),
  );

  /// Menu bar color
  static Color menuBarColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF3A3939)
        : const Color(0xFFE0E0E0);
  }

  /// Menu text color
  static Color menuTextColor(Brightness brightness) {
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
