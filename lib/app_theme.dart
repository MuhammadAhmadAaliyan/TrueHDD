import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Main window bg
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color.fromARGB(255, 206, 206, 206), // Dropdown bg (40% opacity)
      textStyle: TextStyle(color: Colors.black,),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF626262), // Main window bg
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF3A3939), // Dropdown bg
      textStyle: TextStyle(color: Colors.white),
    ),
  );

  /// Menu bar color
  static Color menuBarColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF3A3939)
        : const Color.fromARGB(255, 206, 206, 206);
  }

  /// Menu text color
  static Color menuTextColor(Brightness brightness) {
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
