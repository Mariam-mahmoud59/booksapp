import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF8F5F0);
  static const Color foreground = Color(0xFF5D4037);
  static const Color card = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF8D6E63);
  static const Color secondary = Color(0xFFE8DCCB);
  static const Color muted = Color(0xFFE8DCCB);
  static const Color mutedForeground = Color(0xFF8D6E63);
  static const Color accent = Color(0xFFC8A27C);
  static const Color accentForeground = Color(0xFFFFFFFF);
  static const Color border = Color(0x268D6E63);
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color ring = Color(0xFFB08968);

  static const Color cover1Start = Color(0xFFB08968);
  static const Color cover1End = Color(0xFF8D6E63);
  static const Color cover2Start = Color(0xFFE8DCCB);
  static const Color cover2End = Color(0xFFC8A27C);
  static const Color cover3Start = Color(0xFF8D6E63);
  static const Color cover3End = Color(0xFF5D4037);
  static const Color cover4Start = Color(0xFFC8A27C);
  static const Color cover4End = Color(0xFFB08968);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        secondary: AppColors.secondary,
        onSecondary: AppColors.foreground,
        error: const Color(0xFFD4183D),
        onError: Colors.white,
        surface: AppColors.background,
        onSurface: AppColors.foreground,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Georgia',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.ring, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        hintStyle: const TextStyle(color: AppColors.mutedForeground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.accentForeground,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: AppColors.border),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          color: AppColors.foreground,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          color: AppColors.foreground,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          color: AppColors.foreground,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          color: AppColors.foreground,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.foreground,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.mutedForeground,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.mutedForeground,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }
}
