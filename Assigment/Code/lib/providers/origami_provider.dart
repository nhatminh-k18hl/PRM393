import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class OrigamiModel {
  final String title;
  final String category;
  final String difficulty;
  final double rating;
  final String description;
  final Color previewColor;
  final bool isDownloaded;

  const OrigamiModel({
    required this.title,
    required this.category,
    required this.difficulty,
    required this.rating,
    required this.description,
    required this.previewColor,
    required this.isDownloaded,
  });
}

class OrigamiProvider with ChangeNotifier {
  List<String> _selectedCategories = []; // List for multi-tag Join Filters
  bool _filterDownloadedOnly = false; // Boolean flag to show only local files
  String _searchQuery = '';

  // Mock database
  final List<OrigamiModel> _allModels = [
    const OrigamiModel(
      title: "Legendary Origami Crane",
      category: "Traditional Origami",
      difficulty: "Beginner",
      rating: 4.9,
      description: "The classic paper crane, a symbol of peace, hope, and healing in Japanese culture.",
      previewColor: Color(0xFFEF9A9A),
      isDownloaded: true, // Started as downloaded
    ),
    const OrigamiModel(
      title: "Hopping Tree Frog",
      category: "Origami Animals",
      difficulty: "Intermediate",
      rating: 4.7,
      description: "An action model that actually jumps when you tap its back. Fun for all ages.",
      previewColor: Color(0xFFA5D6A7),
      isDownloaded: false,
    ),
    const OrigamiModel(
      title: "Celestial Lucky Star",
      category: "Origami Stars",
      difficulty: "Easy",
      rating: 4.6,
      description: "Puffy little stars folded from long strips. Make a jar of them for good luck.",
      previewColor: Color(0xFFFFE082),
      isDownloaded: true, // Started as downloaded
    ),
    const OrigamiModel(
      title: "Masu Gift Box",
      category: "Origami Boxes",
      difficulty: "Intermediate",
      rating: 4.8,
      description: "A traditional Japanese box that is perfect for small gifts, desk organization, or snacks.",
      previewColor: Color(0xFFCE93D8),
      isDownloaded: false,
    ),
    const OrigamiModel(
      title: "Dynamic supersonic Jet",
      category: "Origami Vehicles",
      difficulty: "Intermediate",
      rating: 4.8,
      description: "High performance origami airplane optimized for both aerodynamics and visual appeal.",
      previewColor: Color(0xFF90CAF9),
      isDownloaded: true, // Started as downloaded
    ),
    const OrigamiModel(
      title: "Sweet Blossom Tulip",
      category: "Origami Flowers",
      difficulty: "Beginner",
      rating: 4.4,
      description: "A charming flower and stem combination. Perfect for greeting cards and spring bouquets.",
      previewColor: Color(0xFFFFAB91),
      isDownloaded: false,
    ),
    const OrigamiModel(
      title: "Heart Bookmark",
      category: "Origami Hearts",
      difficulty: "Easy",
      rating: 4.7,
      description: "A decorative heart that slips easily over the corner of your page to save your spot.",
      previewColor: Color(0xFFF48FB1),
      isDownloaded: false,
    ),
    const OrigamiModel(
      title: "Traditional Kimono",
      category: "Origami Clothes",
      difficulty: "Beginner",
      rating: 4.5,
      description: "A traditional fold representing a Japanese yukata/kimono garment.",
      previewColor: Color(0xFF80CBC4),
      isDownloaded: false,
    ),
    const OrigamiModel(
      title: "Modular Sonobe Cube",
      category: "Modular Origami",
      difficulty: "Intermediate",
      rating: 4.9,
      description: "A solid cube made from six identical units locked together without glue or scissors.",
      previewColor: Color(0xFFB0BEC5),
      isDownloaded: true, // Started as downloaded
    ),
    const OrigamiModel(
      title: "Simple Paper Plane",
      category: "Beginner Origami",
      difficulty: "Beginner",
      rating: 4.5,
      description: "Standard dart plane design that is easy to fold and flies beautifully.",
      previewColor: Color(0xFF80DEEA),
      isDownloaded: true, // Started as downloaded
    ),
    const OrigamiModel(
      title: "Origami Cat Face",
      category: "Beginner Origami",
      difficulty: "Beginner",
      rating: 4.4,
      description: "Cute animal face that takes just a few folds. Draw on whiskers to finish!",
      previewColor: Color(0xFFFFCC80),
      isDownloaded: false,
    ),
    const OrigamiModel(
      title: "Classic Sailboat",
      category: "Beginner Origami",
      difficulty: "Beginner",
      rating: 4.3,
      description: "A traditional toy that floats on water for a short time. Simple and satisfying.",
      previewColor: Color(0xFF9FA8DA),
      isDownloaded: false,
    ),
  ];

  // Getters
  List<String> get selectedCategories => _selectedCategories;
  bool get filterDownloadedOnly => _filterDownloadedOnly;
  String get searchQuery => _searchQuery;
  List<OrigamiModel> get allModels => _allModels;

  OrigamiProvider() {
    _initLocalCache();
  }

  /// Initialize local device hardware caching using [path_provider]
  Future<void> _initLocalCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      
      // Sync in-memory states with hardware files
      for (int i = 0; i < _allModels.length; i++) {
        final model = _allModels[i];
        final fileName = '${model.title.replaceAll(' ', '_')}.glb';
        final file = File('${dir.path}/$fileName');
        
        if (model.isDownloaded) {
          // If marked downloaded, ensure dummy file exists locally
          if (!await file.exists()) {
            await file.writeAsBytes([0x3D, 0x47, 0x4C, 0x42]); // Simulated GLB header
          }
        } else {
          // If not marked in memory, check if a leftover local file exists on storage
          if (await file.exists()) {
            _allModels[i] = _cloneWithDownloadState(model, true);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing device cache folder: $e");
    }
  }

  // Filtered and Sorted list selection matrix
  List<OrigamiModel> get filteredModels {
    final filtered = _allModels.where((model) {
      // 1. Filter by search text query
      final matchesSearch = _searchQuery.isEmpty ||
          model.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          model.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2. Multi-tag selection logic (Join Filter on category or difficulty tags)
      final matchesCategory = _selectedCategories.isEmpty ||
          _selectedCategories.any((tag) =>
              model.category.toLowerCase() == tag.toLowerCase() ||
              model.difficulty.toLowerCase() == tag.toLowerCase());

      // 3. Downloaded only filter constraint
      final matchesDownload = !_filterDownloadedOnly || model.isDownloaded;

      return matchesSearch && matchesCategory && matchesDownload;
    }).toList();

    // 4. Download Priority sorting matrix (float downloaded items to top)
    filtered.sort((a, b) {
      if (a.isDownloaded && !b.isDownloaded) return -1;
      if (!a.isDownloaded && b.isDownloaded) return 1;
      return b.rating.compareTo(a.rating);
    });

    return filtered;
  }

  // Setters & Actions
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
    _filterDownloadedOnly = false;
    _searchQuery = '';
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Download simulator checking and saving/deleting glb files into local hardware storage
  Future<void> toggleDownload(String title) async {
    final index = _allModels.indexWhere((model) => model.title == title);
    if (index != -1) {
      final model = _allModels[index];
      final targetDownloaded = !model.isDownloaded;

      try {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = '${title.replaceAll(' ', '_')}.glb';
        final file = File('${dir.path}/$fileName');

        if (targetDownloaded) {
          // Write dummy glb byte array to local storage cache path
          await file.writeAsBytes([0x3D, 0x47, 0x4C, 0x42]);
        } else {
          // Remove from local storage cache path
          if (await file.exists()) {
            await file.delete();
          }
        }
      } catch (e) {
        debugPrint("Local file cache update failure: $e");
      }

      // Update state
      _allModels[index] = _cloneWithDownloadState(model, targetDownloaded);
      notifyListeners();
    }
  }

  OrigamiModel _cloneWithDownloadState(OrigamiModel m, bool isDownloaded) {
    return OrigamiModel(
      title: m.title,
      category: m.category,
      difficulty: m.difficulty,
      rating: m.rating,
      description: m.description,
      previewColor: m.previewColor,
      isDownloaded: isDownloaded,
    );
  }
}
