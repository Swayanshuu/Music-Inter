import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A42D1);
  static const Color accent = Color(0xFFFF6584);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF16213E);
  static const Color card = Color(0xFF0F3460);
  static const Color cardLight = Color(0xFF1B2A4A);
  static const Color onSurface = Color(0xFFE0E0FF);
  static const Color onSurfaceMuted = Color(0xFF8888AA);
  static const Color success = Color(0xFF4CAF82);
  static const Color error = Color(0xFFFF6B6B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: onSurface),
          displayMedium: TextStyle(color: onSurface),
          headlineLarge: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: onSurface),
          titleSmall: TextStyle(color: onSurfaceMuted),
          bodyLarge: TextStyle(color: onSurface),
          bodyMedium: TextStyle(color: onSurfaceMuted),
          labelLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A3A5A), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(color: onSurfaceMuted),
        hintStyle: const TextStyle(color: Color(0xFF5A5A7A)),
        prefixIconColor: onSurfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        iconTheme: const IconThemeData(color: onSurface),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardLight,
        contentTextStyle: GoogleFonts.outfit(color: onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
