import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/origami_model.dart';

class OrigamiProvider with ChangeNotifier {
  List<OrigamiModel> _allModels = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  bool _filterDownloadedOnly = false;
  
  String? _appDocDirPath;
  
  List<OrigamiModel> get allModels => _allModels;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<String> get selectedCategories => _selectedCategories;
  bool get filterDownloadedOnly => _filterDownloadedOnly;

  OrigamiProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _appDocDirPath = directory.path;
      
      // Load from local assets/data/origami_database.json
      final jsonString = await rootBundle.loadString('assets/data/origami_database.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _allModels = jsonList.map((j) => OrigamiModel.fromJson(j)).toList();
    } catch (e) {
      debugPrint("Error loading origami database: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isModelDownloaded(String id) {
    if (_appDocDirPath == null) return false;
    final file = File("$_appDocDirPath/models/$id/steps.json");
    return file.existsSync();
  }

  // Get path to specific model's subdirectory
  String getModelDirectoryPath(String id) {
    if (_appDocDirPath == null) return '';
    return "$_appDocDirPath/models/$id";
  }

  // Filtered and Sorted list
  List<OrigamiModel> get visibleOrigamis {
    final filtered = _allModels.where((model) {
      // 1. Text search query match (case-insensitive)
      final matchesSearch = _searchQuery.isEmpty ||
          model.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          model.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2. Multi-tag AND filter matching: must encompass ALL tags in selectedCategories
      final matchesCategories = _selectedCategories.isEmpty ||
          _selectedCategories.every((tag) => model.categories.contains(tag));

      // 3. Downloaded only filter constraint
      final matchesDownloadOnly = !_filterDownloadedOnly || isModelDownloaded(model.id);

      return matchesSearch && matchesCategories && matchesDownloadOnly;
    }).toList();

    // 4. Sorting: downloaded elements bubble to the top, then sort by title
    filtered.sort((a, b) {
      final aDownloaded = isModelDownloaded(a.id);
      final bDownloaded = isModelDownloaded(b.id);
      if (aDownloaded && !bDownloaded) return -1;
      if (!aDownloaded && bDownloaded) return 1;
      return a.title.compareTo(b.title);
    });

    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void toggleDownloadedFilter() {
    _filterDownloadedOnly = !_filterDownloadedOnly;
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedCategories.clear();
    _searchQuery = '';
    _filterDownloadedOnly = false;
    notifyListeners();
  }

  Future<void> pruneModelCache(String origamiId) async {
    if (_appDocDirPath == null) return;
    final dir = Directory("$_appDocDirPath/models/$origamiId");
    try {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint("Error pruning model cache: $e");
    } finally {
      notifyListeners();
    }
  }

  // Helper to force notifyListeners when download completes
  void refreshDownloadStatus() {
    notifyListeners();
  }
}
