import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Main window bg
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFFCECECE), // Dropdown bg (40% opacity)
      textStyle: TextStyle(color: Colors.black),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF626262), // Main window bg
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF3A3939), // Dropdown bg
      textStyle: TextStyle(color: Colors.white),
    ),
  );

  /// Menu bar color
  static Color menuBarAndMainAreaColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF3A3939)
        : const Color(0xFFCECECE);
  }

  ///Tick Color
  static Color tickAndTitleColor(Brightness brightness) {
    return brightness == Brightness.light
        ? Color(0xFF9929EA)
        : Color(0xFFFFFFFF);
  }

  ///Inputs + Dropdowns + LogArea bg Color
  static inputLogAndDropDownBgColor(Brightness brightness) {
    return brightness == Brightness.light
        ? Color(0x1F424141)
        : Color(0x1FFFFFFF);
  }

  ///Text Color
  static textColor(Brightness brightness) {
    return brightness == Brightness.light
        ? Color(0xFF000000)
        : Color(0xFFFFFFFF);
  }

  ///Hint Color
  static hintColor(Brightness brightness) {
    return brightness == Brightness.light
        ? Color(0x4C000000)
        : Color(0x4CFFFFFF);
  }

  /// Log and Analysis Area Text Color
  static logAndAnalysisAreaTextColor(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFF3A3939)
        : const Color(0xFFCECECE);
  }
}
