import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/origami_provider.dart';
import 'product_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSettingsOpen = false;
  final TextEditingController _searchController = TextEditingController();

  // The exact 19 categories specified
  final List<String> _categories = [
    "Beginner Origami",
    "Easy Origami",
    "Intermediate Origami",
    "Holiday Origami",
    "Origami Animals",
    "Traditional Origami",
    "Modular Origami",
    "Origami Boxes",
    "Origami Clothes",
    "Origami Decorations",
    "Origami Stationery",
    "Origami Flowers",
    "Origami Food",
    "Origami Furniture",
    "Origami Hearts",
    "Origami Stars",
    "Origami Toys",
    "Origami Vehicles",
    "Misc Origami"
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final origamiData = Provider.of<OrigamiProvider>(context);
    final filteredModels = origamiData.filteredModels;

    return Scaffold(
      body: Stack(
        children: [
          // Background Matrix
          Positioned.fill(
            child: Container(
              color: settings.backgroundColor,
              child: const CustomGridBackground(),
            ),
          ),

          // Main Layout Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row
                _buildHeader(settings, origamiData),

                // Join Filter Controls Row (Downloaded Only toggle & Clear Filters)
                _buildFilterControlsRow(settings, origamiData),

                // Category Scrollable Row Banner (Multi-Tag Lane)
                _buildCategoryBanner(settings, origamiData),

                // Center Workspace: Discover Grid List
                Expanded(
                  child: filteredModels.isEmpty
                      ? _buildEmptyState(settings)
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.45,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredModels.length,
                          itemBuilder: (context, index) {
                            final model = filteredModels[index];
                            return _buildModelCard(context, model, settings);
                          },
                        ),
                ),
              ],
            ),
          ),

          // Settings Blur Overlay & Sliding Drawer
          if (_isSettingsOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSettingsOpen = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

          // Settings Slider Panel Drawer (Slide in from right)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            right: _isSettingsOpen ? 0 : -380,
            child: GestureDetector(
              onTap: () {}, // Prevent click-through from closing panel
              child: _buildSettingsDrawer(settings),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppSettingsProvider settings, OrigamiProvider origamiData) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Row(
        children: [
          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '3D OriMaster',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: settings.primaryColor,
                ),
              ),
              const Text(
                'Discover & Fold',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
          // Search Field
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search models...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 18, color: Colors.white54),
                  suffixIcon: origamiData.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.white54),
                          onPressed: () {
                            origamiData.setSearchQuery('');
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (val) {
                  origamiData.setSearchQuery(val);
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Gear Configuration Icon Button
          Material(
            color: Colors.white.withOpacity(0.08),
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(Icons.settings, color: settings.primaryColor, size: 20),
              tooltip: 'Settings Config',
              onPressed: () {
                setState(() {
                  _isSettingsOpen = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControlsRow(AppSettingsProvider settings, OrigamiProvider origamiData) {
    // Shows clear button only if any tags are selected, downloaded filter is active, or search query is populated
    final bool showClear = origamiData.selectedCategories.isNotEmpty ||
        origamiData.filterDownloadedOnly ||
        origamiData.searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
      child: Row(
        children: [
          // "Downloaded Only" filter toggle
          InkWell(
            onTap: () {
              origamiData.toggleDownloadedFilter();
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: origamiData.filterDownloadedOnly
                    ? settings.primaryColor.withOpacity(0.15)
                    : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: origamiData.filterDownloadedOnly
                      ? settings.primaryColor
                      : Colors.white12,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    origamiData.filterDownloadedOnly ? Icons.offline_pin : Icons.offline_pin_outlined,
                    color: origamiData.filterDownloadedOnly ? settings.primaryColor : Colors.white60,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Downloaded Only',
                    style: TextStyle(
                      fontSize: 11,
                      color: origamiData.filterDownloadedOnly ? Colors.white : Colors.white60,
                      fontWeight: origamiData.filterDownloadedOnly ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // "Clear All Filters" (Xóa Lọc) fading action button
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: showClear ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !showClear,
              child: TextButton.icon(
                onPressed: () {
                  origamiData.clearAllFilters();
                  _searchController.clear();
                },
                icon: const Icon(Icons.filter_alt_off, size: 14, color: Colors.redAccent),
                label: const Text(
                  'Clear All Filters (Xóa Lọc)',
                  style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  backgroundColor: Colors.redAccent.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.redAccent, width: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBanner(AppSettingsProvider settings, OrigamiProvider origamiData) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = origamiData.selectedCategories.contains(cat);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 4, bottom: 4),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: settings.primaryColor,
              backgroundColor: Colors.white.withOpacity(0.05),
              checkmarkColor: Colors.white,
              onSelected: (selected) {
                origamiData.toggleCategory(cat);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildModelCard(BuildContext context, OrigamiModel model, AppSettingsProvider settings) {
    return GestureDetector(
      onTap: () {
        // Render Product Detail overlay (Screen 3)
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Detail',
          barrierColor: Colors.black.withOpacity(0.6),
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, anim1, anim2) {
            return ProductDetailScreen(model: model);
          },
          transitionBuilder: (context, anim1, anim2, child) {
            return FadeTransition(
              opacity: anim1,
              child: ScaleTransition(
                scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
                child: child,
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.01),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview shape section
            Expanded(
              child: Container(
                color: Colors.white.withOpacity(0.03),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // A rotating geometric triangle container representation
                    RotationTransition(
                      turns: const AlwaysStoppedAnimation(45 / 360),
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: model.previewColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: model.previewColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    // Rating indicator (Top Right)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              model.rating.toString(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Local storage / Download status badge (Top Left)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () async {
                          // Simulates caching .glb files into getApplicationDocumentsDirectory()
                          await Provider.of<OrigamiProvider>(context, listen: false)
                              .toggleDownload(model.title);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  model.isDownloaded 
                                      ? "Removed cached GLB model" 
                                      : "Saved model GLB into documents folder!",
                                  style: const TextStyle(fontSize: 11),
                                ),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                width: 300,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: model.isDownloaded ? Colors.greenAccent : Colors.white24,
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            model.isDownloaded ? Icons.offline_pin : Icons.cloud_download,
                            color: model.isDownloaded ? Colors.greenAccent : Colors.white70,
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info text block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        model.difficulty,
                        style: TextStyle(
                          fontSize: 10,
                          color: settings.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        "15x15 cm",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppSettingsProvider settings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 50, color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'No models found matching parameters',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try switching categories or clearing queries',
            style: TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsDrawer(AppSettingsProvider settings) {
    final List<Color> primaries = [
      const Color(0xFFFF5722), // Terracotta
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF009688), // Teal
      const Color(0xFFE91E63), // Pink
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
    ];

    final List<Color> backgrounds = [
      const Color(0xFF1E1E2C), // Dark Blue Grey
      const Color(0xFF121212), // Pitch Black
      const Color(0xFF1F1F1F), // Dark Slate
      const Color(0xFF2D142C), // Dark Aubergine
    ];

    final List<Color> paperColors = [
      const Color(0xFFFFCC80), // Orange Yellow
      const Color(0xFFFFB7B2), // Soft Rose
      const Color(0xFFB5EAD7), // Mint Green
      const Color(0xFFE2F0CB), // Pastel Lime
      const Color(0xFFC7CEEA), // Soft Lilac
      const Color(0xFFFFFFFF), // Plain White
    ];

    final List<String> fonts = ['Verdana', 'Courier New', 'Georgia'];
    final List<double> scales = [0.5, 0.75, 1.0, 1.25, 1.5];

    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: const Color(0xFF161622).withOpacity(0.95),
        border: const Border(
          left: BorderSide(color: Colors.white12, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          )
        ],
      ),
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: settings.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Visual Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () {
                      setState(() {
                        _isSettingsOpen = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            // Settings Options List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Primary theme color
                  _buildSectionHeader('Theme Primary Color'),
                  const SizedBox(height: 8),
                  Row(
                    children: primaries.map((color) {
                      final isSel = settings.primaryColor.value == color.value;
                      return GestureDetector(
                        onTap: () => settings.setPrimaryColor(color),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? Colors.white : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          child: isSel
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Background tint color
                  _buildSectionHeader('App Background Tint'),
                  const SizedBox(height: 8),
                  Row(
                    children: backgrounds.map((color) {
                      final isSel = settings.backgroundColor.value == color.value;
                      return GestureDetector(
                        onTap: () => settings.setBackgroundColor(color),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? settings.primaryColor : Colors.white30,
                              width: 2.0,
                            ),
                          ),
                          child: isSel
                              ? Icon(Icons.check, color: settings.primaryColor, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 3D Model paper color
                  _buildSectionHeader('3D Model Paper Simulation'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: paperColors.map((color) {
                      final isSel = settings.paperColor.value == color.value;
                      return GestureDetector(
                        onTap: () => settings.setPaperColor(color),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? settings.primaryColor : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSel
                              ? Icon(Icons.check, color: settings.primaryColor, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Typography selection
                  _buildSectionHeader('Typography Font Family'),
                  const SizedBox(height: 8),
                  Column(
                    children: fonts.map((font) {
                      final isSel = settings.currentFont == font;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSel ? settings.primaryColor.withOpacity(0.15) : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? settings.primaryColor : Colors.transparent,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            font,
                            style: TextStyle(
                              fontFamily: font,
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSel ? Icon(Icons.check_circle, color: settings.primaryColor, size: 16) : null,
                          onTap: () => settings.setCurrentFont(font),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Layout scale percentage picker
                  _buildSectionHeader('Global Layout Sizing Scale'),
                  const SizedBox(height: 8),
                  Row(
                    children: scales.map((scale) {
                      final isSel = settings.globalScale == scale;
                      final int percent = (scale * 100).toInt();
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => settings.setGlobalScale(scale),
                          child: Container(
                            height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isSel ? settings.primaryColor : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$percent%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                color: isSel ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  // Reset defaults button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                      foregroundColor: Colors.redAccent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.redAccent, width: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      settings.resetToDefaults();
                    },
                    child: const Text('Reset Defaults', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.white38,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Custom abstract grid background to wow the user.
class CustomGridBackground extends StatelessWidget {
  const CustomGridBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1.0;

    const double step = 40.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
