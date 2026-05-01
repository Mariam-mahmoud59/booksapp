import 'package:flutter/material.dart';

class AppColors {
  static Color background = const Color(0xFFF8F5F0);
  static Color foreground = const Color(0xFF5D4037);
  static Color card = const Color(0xFFFFFFFF);
  static Color primary = const Color(0xFF8D6E63);
  static Color secondary = const Color(0xFFE8DCCB);
  static Color muted = const Color(0xFFE8DCCB);
  static Color mutedForeground = const Color(0xFF8D6E63);
  static Color accent = const Color(0xFFC8A27C);
  static Color accentForeground = const Color(0xFFFFFFFF);
  static Color border = const Color(0x268D6E63);
  static Color inputBackground = const Color(0xFFFFFFFF);
  static Color ring = const Color(0xFFB08968);

  static Color cover1Start = const Color(0xFFB08968);
  static Color cover1End = const Color(0xFF8D6E63);
  static Color cover2Start = const Color(0xFFE8DCCB);
  static Color cover2End = const Color(0xFFC8A27C);
  static Color cover3Start = const Color(0xFF8D6E63);
  static Color cover3End = const Color(0xFF5D4037);
  static Color cover4Start = const Color(0xFFC8A27C);
  static Color cover4End = const Color(0xFFB08968);
}

/// ── Unified font sizes used across the app ──
class AppTextSize {
  /// 32 — Page titles / hero headings
  static const double displayLarge = 32;
  /// 28 — Screen headers ("Favorites", "Profile" …)
  static const double displayMedium = 28;
  /// 24 — Section titles
  static const double headingLarge = 24;
  /// 20 — Sub-section headings
  static const double headingMedium = 20;
  /// 18 — Card / list headings
  static const double headingSmall = 18;
  /// 16 — Body text / story titles in cards
  static const double bodyLarge = 16;
  /// 15 — Action item titles
  static const double bodyMedium = 15;
  /// 14 — Secondary body text / page count
  static const double bodySmall = 14;
  /// 13 — Helper / label text
  static const double labelLarge = 13;
  /// 12 — Timestamps / muted info
  static const double labelMedium = 12;
  /// 11 — Caps section labels ("ACCOUNT", "GENRE" …)
  static const double labelSmall = 11;
  /// 10 — Tiny badges / genre chips
  static const double micro = 10;
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
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.ring, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        hintStyle: TextStyle(color: AppColors.mutedForeground),
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
          side: BorderSide(color: AppColors.border),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textTheme: TextTheme(
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
