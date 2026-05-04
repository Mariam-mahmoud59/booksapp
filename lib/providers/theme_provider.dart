import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

enum AppFontSize { small, medium, large }

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  static const String _fontSizeKey = 'app_font_size';
  
  bool _isDarkMode = false;
  AppFontSize _fontSize = AppFontSize.medium;

  bool get isDarkMode => _isDarkMode;
  AppFontSize get fontSize => _fontSize;

  String get fontSizeName {
    switch (_fontSize) {
      case AppFontSize.small: return 'Small';
      case AppFontSize.large: return 'Large';
      default: return 'Medium';
    }
  }

  double get fontSizeMultiplier {
    switch (_fontSize) {
      case AppFontSize.small: return 0.85;
      case AppFontSize.large: return 1.25;
      default: return 1.0;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    
    final fontSizeIndex = prefs.getInt(_fontSizeKey) ?? 1; // Default to Medium (index 1)
    _fontSize = AppFontSize.values[fontSizeIndex];

    _applyTheme();
    _updateSystemUI();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    _applyTheme();
    _updateSystemUI();
    notifyListeners();
  }

  Future<void> setFontSize(AppFontSize size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontSizeKey, size.index);
    notifyListeners();
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _isDarkMode ? AppColors.dBackground : AppColors.lBackground,
        systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }

  void _applyTheme() {
    if (_isDarkMode) {
      AppColors.background = AppColors.dBackground;
      AppColors.foreground = AppColors.dForeground;
      AppColors.card = AppColors.dCard;
      AppColors.primary = AppColors.dPrimary;
      AppColors.secondary = AppColors.dSecondary;
      AppColors.muted = AppColors.dMuted;
      AppColors.mutedForeground = AppColors.dMutedForeground;
      AppColors.accent = AppColors.dAccent;
      AppColors.accentForeground = AppColors.dAccentForeground;
      AppColors.border = AppColors.dBorder;
      AppColors.inputBackground = AppColors.dInputBackground;
      AppColors.ring = AppColors.dRing;
    } else {
      AppColors.background = AppColors.lBackground;
      AppColors.foreground = AppColors.lForeground;
      AppColors.card = AppColors.lCard;
      AppColors.primary = AppColors.lPrimary;
      AppColors.secondary = AppColors.lSecondary;
      AppColors.muted = AppColors.lMuted;
      AppColors.mutedForeground = AppColors.lMutedForeground;
      AppColors.accent = AppColors.lAccent;
      AppColors.accentForeground = AppColors.lAccentForeground;
      AppColors.border = AppColors.lBorder;
      AppColors.inputBackground = AppColors.lInputBackground;
      AppColors.ring = AppColors.lRing;
    }
  }
}
