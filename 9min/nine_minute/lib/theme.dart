import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Backgrounds
  static const Color background = Color(0xFF000000);
  static const Color secondaryBackground = Color(0xFF111111);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color divider = Color(0xFF2A2A2A);

  // Text
  static const Color textPrimary = Color(0xFFF7F7F5);
  static const Color textSecondary = Color(0xFFB8B8B8);

  // Accent — mapped to primary text for a monochrome palette.
  // Names kept for compatibility across existing screens.
  static const Color primaryTeal = Color(0xFFF7F7F5);
  static const Color accentCyan = Color(0xFFF7F7F5);

  static String? get _serifFamily => GoogleFonts.ibmPlexSerif().fontFamily;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      shadowColor: Colors.transparent,
      fontFamily: _serifFamily,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: textPrimary,
        secondary: textSecondary,
        onPrimary: background,
        onSecondary: background,
        onSurface: textPrimary,
      ),
      dividerColor: divider,
      cardTheme: const CardThemeData(
        color: surface,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.ibmPlexSerif(
          fontSize: 40,
          fontWeight: FontWeight.w300,
          color: textPrimary,
          letterSpacing: 1.0,
        ),
        headlineMedium: GoogleFonts.ibmPlexSerif(
          fontSize: 28,
          fontWeight: FontWeight.w300,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        bodyLarge: GoogleFonts.ibmPlexSerif(
          fontSize: 20,
          fontWeight: FontWeight.w300,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.ibmPlexSerif(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textPrimary,
          foregroundColor: background,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.ibmPlexSerif(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
