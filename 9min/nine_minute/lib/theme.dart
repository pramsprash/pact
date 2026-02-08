import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color primaryTeal = Color(0xFF0F9690);
  static const Color accentCyan = Color(0xFF53D8D8);
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFFB0B0C0);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: accentCyan,
        surface: surface,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w300,
          color: textPrimary,
          letterSpacing: 2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w300,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w300,
          color: textSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
