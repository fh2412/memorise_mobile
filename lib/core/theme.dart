import 'package:flutter/material.dart';

class MemoriseTheme {
  // Extracting core colors from your SASS palettes
  static const Color _primaryColor = Color(0xFF305EA0); // Palette 40
  static const Color _secondaryColor = Color(0xFFFFA500); // Palette 40
  static const Color _tertiaryColor = Color(0xFF006B23); // Palette 40

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        primary: _primaryColor,
        secondary: _secondaryColor,
        tertiary: _tertiaryColor,
        surface: const Color(0xFFF9F9FF), // Palette 98 Neutral
        error: const Color(0xFFBA1A1A), // Palette 40 Error
      ),
      // Customizing component themes to match Material 3 specs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F6), // Palette 95 Neutral
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  // You can easily add a darkTheme here using palette 80 tones
}
