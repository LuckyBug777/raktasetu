import 'package:flutter/material.dart';

/// RaktaSetu Material 3 Theme
class AppTheme {
  static const Color bloodRed = Color(0xFF8B0000);
  static const Color softGray = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF333333);
  static const Color lightGray = Color(0xFFEEEEEE);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE63946);
  static const Color warningOrange = Color(0xFFFFA500);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: bloodRed,
        brightness: Brightness.light,
        primary: bloodRed,
        secondary: const Color(0xFFF06292),
        tertiary: const Color(0xFF00BCD4),
        error: errorRed,
        surface: white,
      ),
      scaffoldBackgroundColor: softGray,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: bloodRed,
        foregroundColor: white,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: bloodRed,
        brightness: Brightness.dark,
        primary: bloodRed,
        secondary: const Color(0xFFF06292),
        error: errorRed,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
