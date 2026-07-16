import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  static final PreferencesService _instance = PreferencesService._internal();
  static PreferencesService get instance => _instance;

  PreferencesService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Real-time cached variables
  int _themeModeIndex = 0; // 0 = Light, 1 = Dark, 2 = Book Sync
  String _lastReadBookId = '';
  double _currentFontSize = 18.0;
  String _currentFontFamily = 'Quicksand';
  List<String> _bookmarks = [];

  // Getters
  int get themeModeIndex => _themeModeIndex;
  bool get isDarkMode => _themeModeIndex == 1;
  String get lastReadBookId => _lastReadBookId;
  double get currentFontSize => _currentFontSize;
  String get currentFontFamily => _currentFontFamily;
  List<String> get bookmarks => _bookmarks;

  // Initialize service from disk
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();

    _themeModeIndex = _prefs.getInt('themeModeIndex') ?? 0;
    _lastReadBookId = _prefs.getString('lastReadBookId') ?? '';
    _currentFontSize = _prefs.getDouble('currentFontSize') ?? 18.0;
    _currentFontFamily = _prefs.getString('currentFontFamily') ?? 'Quicksand';
    _bookmarks = _prefs.getStringList('bookmarks') ?? [];
    
    _isInitialized = true;
    notifyListeners();
  }

  // Setters with disk synchronization
  Future<void> setThemeModeIndex(int index) async {
    if (index >= 0 && index <= 2) {
      _themeModeIndex = index;
      await _prefs.setInt('themeModeIndex', index);
      notifyListeners();
    }
  }

  Future<void> setLastReadBookId(String bookId) async {
    _lastReadBookId = bookId;
    await _prefs.setString('lastReadBookId', bookId);
    notifyListeners();
  }

  Future<void> setCurrentFontSize(double size) async {
    _currentFontSize = size;
    await _prefs.setDouble('currentFontSize', size);
    notifyListeners();
  }

  Future<void> setCurrentFontFamily(String family) async {
    _currentFontFamily = family;
    await _prefs.setString('currentFontFamily', family);
    notifyListeners();
  }

  bool isBookmarked(String bookId, String chapterId) {
    return _bookmarks.contains('${bookId}_$chapterId');
  }

  Future<void> toggleBookmark(String bookId, String chapterId) async {
    final key = '${bookId}_$chapterId';
    if (_bookmarks.contains(key)) {
      _bookmarks.remove(key);
    } else {
      _bookmarks.add(key);
    }
    await _prefs.setStringList('bookmarks', _bookmarks);
    notifyListeners();
  }
}
