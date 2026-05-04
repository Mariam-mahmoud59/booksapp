import 'package:flutter/material.dart';

class AppColors {
  // Light Palette
  static const Color lBackground = Color(0xFFF8F5F0);
  static const Color lForeground = Color(0xFF5D4037);
  static const Color lCard = Color(0xFFFFFFFF);
  static const Color lPrimary = Color(0xFF8D6E63);
  static const Color lSecondary = Color(0xFFE8DCCB);
  static const Color lMuted = Color(0xFFE8DCCB);
  static const Color lMutedForeground = Color(0xFF8D6E63);
  static const Color lAccent = Color(0xFFC8A27C);
  static const Color lAccentForeground = Color(0xFFFFFFFF);
  static const Color lBorder = Color(0x268D6E63);
  static const Color lInputBackground = Color(0xFFFFFFFF);
  static const Color lRing = Color(0xFFB08968);

  // Dark Palette
  static const Color dBackground = Color(0xFF121212);
  static const Color dForeground = Color(0xFFE8DCCB);
  static const Color dCard = Color(0xFF1E1E1E);
  static const Color dPrimary = Color(0xFFC8A27C);
  static const Color dSecondary = Color(0xFF2D2D2D);
  static const Color dMuted = Color(0xFF2D2D2D);
  static const Color dMutedForeground = Color(0xFFA0A0A0);
  static const Color dAccent = Color(0xFFD4A373);
  static const Color dAccentForeground = Color(0xFF121212);
  static const Color dBorder = Color(0x33FFFFFF);
  static const Color dInputBackground = Color(0xFF1E1E1E);
  static const Color dRing = Color(0xFFD4A373);

  // Mutable getters for backward compatibility during transition
  // These will be updated by ThemeProvider for now, but we should move away from them.
  static Color background = lBackground;
  static Color foreground = lForeground;
  static Color card = lCard;
  static Color primary = lPrimary;
  static Color secondary = lSecondary;
  static Color muted = lMuted;
  static Color mutedForeground = lMutedForeground;
  static Color accent = lAccent;
  static Color accentForeground = lAccentForeground;
  static Color border = lBorder;
  static Color inputBackground = lInputBackground;
  static Color ring = lRing;

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
  static const double displayLarge = 32;
  static const double displayMedium = 28;
  static const double headingLarge = 24;
  static const double headingMedium = 20;
  static const double headingSmall = 18;
  static const double bodyLarge = 16;
  static const double bodyMedium = 15;
  static const double bodySmall = 14;
  static const double labelLarge = 13;
  static const double labelMedium = 12;
  static const double labelSmall = 11;
  static const double micro = 10;
}

class AppTheme {
  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color bg = isDark ? AppColors.dBackground : AppColors.lBackground;
    final Color fg = isDark ? AppColors.dForeground : AppColors.lForeground;
    final Color card = isDark ? AppColors.dCard : AppColors.lCard;
    final Color primary = isDark ? AppColors.dPrimary : AppColors.lPrimary;
    final Color secondary = isDark ? AppColors.dSecondary : AppColors.lSecondary;
    final Color accent = isDark ? AppColors.dAccent : AppColors.lAccent;
    final Color accentFg = isDark ? AppColors.dAccentForeground : AppColors.lAccentForeground;
    final Color mutedFg = isDark ? AppColors.dMutedForeground : AppColors.lMutedForeground;
    final Color border = isDark ? AppColors.dBorder : AppColors.lBorder;
    final Color inputBg = isDark ? AppColors.dInputBackground : AppColors.lInputBackground;
    final Color ring = isDark ? AppColors.dRing : AppColors.lRing;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: secondary,
        onSecondary: fg,
        error: const Color(0xFFD4183D),
        onError: Colors.white,
        surface: bg,
        onSurface: fg,
        surfaceContainerHighest: card,
      ),
      scaffoldBackgroundColor: bg,
      fontFamily: 'Georgia',
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ring, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        hintStyle: TextStyle(color: mutedFg),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accentFg,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: border),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, color: fg, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28, color: fg, fontWeight: FontWeight.w600),
        headlineLarge: TextStyle(fontSize: 24, color: fg, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 20, color: fg, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, color: fg),
        bodyMedium: TextStyle(fontSize: 14, color: fg.withValues(alpha: 0.8)),
        bodySmall: TextStyle(fontSize: 12, color: mutedFg),
        labelSmall: TextStyle(fontSize: 10, color: mutedFg),
      ),
    );
  }
}
