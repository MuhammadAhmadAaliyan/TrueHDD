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

  ///Switch Track Color
  static switchTrackColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? Color(0xFFc17cf2)
        : Color(0xFF9929EA);
  }

  ///Switch Thumb Color
  static switchThumbColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? Color(0xFF3c0960)
        : Color(0xFFFFFFFF);
  }

  /// Gradient for Cancel Button
  static LinearGradient cancelButtonGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? const LinearGradient(
            colors: [Color(0xFFFF2727), Color(0xFF8000FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFF2727), Color(0xFFFF2727)], // Solid Red
          );
  }

  /// Gradient for Decode Button
  static LinearGradient buttonGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? const LinearGradient(
            colors: [Color(0xFF9929EA), Color(0xFFE754FF)], // Purple → Pink
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF9929EA), Color(0xFF9929EA)], // Solid Purple
          );
  }

/// Gradient Border for Info Button
static LinearGradient infoButtonBorderGradient(Brightness brightness) {
  return brightness == Brightness.dark
      ? const LinearGradient(
          colors: [Color(0xFF9929EA), Color(0xFFE754FF)], // Purple → Pink
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFF9929EA), Color(0xFF9929EA)], // Solid purple border
        );
}

}
