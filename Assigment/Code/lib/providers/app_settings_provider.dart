import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider with ChangeNotifier {
  // Defaults
  static const Color defaultPrimaryColor = Color(0xFFFF5722); // Origami Terracotta / Orange
  static const Color defaultBackgroundColor = Color(0xFF1E1E2C); // Deep Charcoal Blue
  static const Color defaultPaperColor = Color(0xFFFFCC80); // Classic Washi Paper Orange/Yellow
  static const String defaultFont = 'Verdana';
  static const double defaultScale = 1.0;

  Color _primaryColor = defaultPrimaryColor;
  Color _backgroundColor = defaultBackgroundColor;
  Color _paperColor = defaultPaperColor;
  String _currentFont = defaultFont;
  double _globalScale = defaultScale;

  // Getters
  Color get primaryColor => _primaryColor;
  Color get backgroundColor => _backgroundColor;
  Color get paperColor => _paperColor;
  String get currentFont => _currentFont;
  double get globalScale => _globalScale;

  AppSettingsProvider() {
    _loadFromPrefs();
  }

  // Setters
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('primaryColor', color.value);
    } catch (e) {
      debugPrint("Error writing primaryColor preference: $e");
    }
  }

  Future<void> setBackgroundColor(Color color) async {
    _backgroundColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('backgroundColor', color.value);
    } catch (e) {
      debugPrint("Error writing backgroundColor preference: $e");
    }
  }

  Future<void> setPaperColor(Color color) async {
    _paperColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('paperColor', color.value);
    } catch (e) {
      debugPrint("Error writing paperColor preference: $e");
    }
  }

  Future<void> setCurrentFont(String font) async {
    _currentFont = font;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentFont', font);
    } catch (e) {
      debugPrint("Error writing currentFont preference: $e");
    }
  }

  Future<void> setGlobalScale(double scale) async {
    _globalScale = scale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('globalScale', scale);
    } catch (e) {
      debugPrint("Error writing globalScale preference: $e");
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPrimary = prefs.getInt('primaryColor');
      if (savedPrimary != null) _primaryColor = Color(savedPrimary);

      final savedBg = prefs.getInt('backgroundColor');
      if (savedBg != null) _backgroundColor = Color(savedBg);

      final savedPaper = prefs.getInt('paperColor');
      if (savedPaper != null) _paperColor = Color(savedPaper);

      final savedFont = prefs.getString('currentFont');
      if (savedFont != null) _currentFont = savedFont;

      final savedScale = prefs.getDouble('globalScale');
      if (savedScale != null) _globalScale = savedScale;

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading preferences: $e");
    }
  }

  Future<void> resetToDefaults() async {
    _primaryColor = defaultPrimaryColor;
    _backgroundColor = defaultBackgroundColor;
    _paperColor = defaultPaperColor;
    _currentFont = defaultFont;
    _globalScale = defaultScale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('primaryColor');
      await prefs.remove('backgroundColor');
      await prefs.remove('paperColor');
      await prefs.remove('currentFont');
      await prefs.remove('globalScale');
    } catch (e) {
      debugPrint("Error resetting preferences: $e");
    }
  }
}
