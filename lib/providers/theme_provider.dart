import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    _applyTheme();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    _applyTheme();
    notifyListeners();
  }

  void _applyTheme() {
    if (_isDarkMode) {
      AppColors.background = const Color(0xFF1A1A1A);
      AppColors.foreground = const Color(0xFFE8DCCB);
      AppColors.card = const Color(0xFF2D2D2D);
      AppColors.primary = const Color(0xFFC8A27C);
      AppColors.secondary = const Color(0xFF3D3D3D);
      AppColors.muted = const Color(0xFF4D4D4D);
      AppColors.mutedForeground = const Color(0xFFA0A0A0);
      AppColors.accent = const Color(0xFFD4A373);
      AppColors.accentForeground = const Color(0xFF1A1A1A);
      AppColors.border = const Color(0x33FFFFFF);
      AppColors.inputBackground = const Color(0xFF2D2D2D);
      AppColors.ring = const Color(0xFFD4A373);
    } else {
      AppColors.background = const Color(0xFFF8F5F0);
      AppColors.foreground = const Color(0xFF5D4037);
      AppColors.card = const Color(0xFFFFFFFF);
      AppColors.primary = const Color(0xFF8D6E63);
      AppColors.secondary = const Color(0xFFE8DCCB);
      AppColors.muted = const Color(0xFFE8DCCB);
      AppColors.mutedForeground = const Color(0xFF8D6E63);
      AppColors.accent = const Color(0xFFC8A27C);
      AppColors.accentForeground = const Color(0xFFFFFFFF);
      AppColors.border = const Color(0x268D6E63);
      AppColors.inputBackground = const Color(0xFFFFFFFF);
      AppColors.ring = const Color(0xFFB08968);
    }
  }
}
