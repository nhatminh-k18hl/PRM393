import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  LIGHT_CLASSIC,
  DARK_SLATE,
  CYBERPUNK_VOID,
  SEPIA_WARM,
  FOREST_MOSS,
  BLACK_OCEAN,
}

extension AppThemeExtension on AppTheme {
  Color get canvasColor {
    switch (this) {
      case AppTheme.LIGHT_CLASSIC:
        return const Color(0xFFFDFBF7);
      case AppTheme.DARK_SLATE:
        return const Color(0xFF121212);
      case AppTheme.CYBERPUNK_VOID:
        return const Color(0xFF0A0E17);
      case AppTheme.SEPIA_WARM:
        return const Color(0xFFF4ECD8);
      case AppTheme.FOREST_MOSS:
        return const Color(0xFF2D3A2E);
      case AppTheme.BLACK_OCEAN:
        return const Color(0xFF0F1E36);
    }
  }

  Color get textColor {
    switch (this) {
      case AppTheme.LIGHT_CLASSIC:
        return const Color(0xFF2B2B2B);
      case AppTheme.DARK_SLATE:
        return const Color(0xFFE0E0E0);
      case AppTheme.CYBERPUNK_VOID:
        return const Color(0xFFF72585);
      case AppTheme.SEPIA_WARM:
        return const Color(0xFF4A3B32);
      case AppTheme.FOREST_MOSS:
        return const Color(0xFFF1EFE0);
      case AppTheme.BLACK_OCEAN:
        return const Color(0xFFE0F7FA);
    }
  }

  Color get activePaperColor {
    switch (this) {
      case AppTheme.LIGHT_CLASSIC:
        return const Color(0xFFD32F2F);
      case AppTheme.DARK_SLATE:
        return const Color(0xFF00B4D8);
      case AppTheme.CYBERPUNK_VOID:
        return const Color(0xFF39FF14);
      case AppTheme.SEPIA_WARM:
        return const Color(0xFFE65100);
      case AppTheme.FOREST_MOSS:
        return const Color(0xFFFFB74D);
      case AppTheme.BLACK_OCEAN:
        return const Color(0xFFFF7043);
    }
  }
}

class AppSettingsProvider with ChangeNotifier {
  AppTheme _activeTheme = AppTheme.DARK_SLATE;
  String _currentFont = 'Verdana';
  double _globalScale = 1.0;

  AppTheme get activeTheme => _activeTheme;
  Color get primaryColor => _activeTheme.activePaperColor;
  Color get backgroundColor => _activeTheme.canvasColor;
  Color get paperColor => _activeTheme.activePaperColor;
  Color get textColor => _activeTheme.textColor;
  String get currentFont => _currentFont;
  double get globalScale => _globalScale;

  AppSettingsProvider() {
    _loadFromPrefs();
  }

  Future<void> setTheme(AppTheme theme) async {
    _activeTheme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('activeThemeIndex', theme.index);
  }

  Future<void> setCurrentFont(String font) async {
    _currentFont = font;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentFont', font);
  }

  Future<void> setGlobalScale(double scale) async {
    _globalScale = scale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('globalScale', scale);
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final savedThemeIndex = prefs.getInt('activeThemeIndex');
      if (savedThemeIndex != null && savedThemeIndex >= 0 && savedThemeIndex < AppTheme.values.length) {
        _activeTheme = AppTheme.values[savedThemeIndex];
      }

      final savedFont = prefs.getString('currentFont');
      if (savedFont != null) {
        _currentFont = savedFont;
      }

      final savedScale = prefs.getDouble('globalScale');
      if (savedScale != null) {
        _globalScale = savedScale;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading settings preferences: $e");
    }
  }

  Future<void> resetToDefaults() async {
    _activeTheme = AppTheme.DARK_SLATE;
    _currentFont = 'Verdana';
    _globalScale = 1.0;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('activeThemeIndex');
      await prefs.remove('currentFont');
      await prefs.remove('globalScale');
    } catch (e) {
      debugPrint("Error resetting preferences: $e");
    }
  }
}
