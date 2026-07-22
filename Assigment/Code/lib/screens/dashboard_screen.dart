import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/origami_provider.dart';
import '../models/origami_model.dart';
import 'add_origami_dialog.dart';
import 'product_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSettingsOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final origamiData = Provider.of<OrigamiProvider>(context);
    final visibleModels = origamiData.visibleOrigamis;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddOrigamiDialog(),
          );
        },
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Add Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
      body: Stack(
        children: [
          // Background canvas
          Positioned.fill(
            child: Container(
              color: settings.backgroundColor,
              child: const CustomGridBackground(),
            ),
          ),

          // Main Layout
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row
                _buildHeader(settings, origamiData),

                // Join Filter Row: Downloaded Only and Xóa Lọc
                _buildFilterControlsRow(settings, origamiData),

                // Category scrollable lane
                _buildCategoryBanner(settings, origamiData),

                // Grid list
                Expanded(
                  child: origamiData.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : visibleModels.isEmpty
                          ? _buildEmptyState(settings)
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.45,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: visibleModels.length,
                              itemBuilder: (context, index) {
                                final model = visibleModels[index];
                                return _buildModelCard(context, model, settings, origamiData);
                              },
                            ),
                ),
              ],
            ),
          ),

          // Settings Blur Overlay & Sliding Drawer
          if (_isSettingsOpen) ...[
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
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              right: 0,
              child: _buildSettingsDrawer(settings),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(AppSettingsProvider settings, OrigamiProvider origamiData) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Row(
        children: [
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
              Text(
                'Discover & Fold',
                style: TextStyle(
                  fontSize: 11,
                  color: settings.textColor.withOpacity(0.6),
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
                color: settings.textColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: settings.textColor.withOpacity(0.12)),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 13, color: settings.textColor),
                decoration: InputDecoration(
                  hintText: 'Search models...',
                  hintStyle: TextStyle(color: settings.textColor.withOpacity(0.4), fontSize: 13),
                  prefixIcon: Icon(Icons.search, size: 18, color: settings.textColor.withOpacity(0.6)),
                  suffixIcon: origamiData.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, size: 16, color: settings.textColor.withOpacity(0.6)),
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
          // Settings button
          Material(
            color: settings.textColor.withOpacity(0.08),
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(Icons.settings, color: settings.primaryColor, size: 20),
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
    final bool isFilterActive = origamiData.selectedCategories.isNotEmpty ||
        origamiData.searchQuery.isNotEmpty ||
        origamiData.filterDownloadedOnly;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
      child: Row(
        children: [
          // Downloaded Only switch
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
                    : settings.textColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: origamiData.filterDownloadedOnly
                      ? settings.primaryColor
                      : settings.textColor.withOpacity(0.12),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    origamiData.filterDownloadedOnly ? Icons.offline_pin : Icons.offline_pin_outlined,
                    color: origamiData.filterDownloadedOnly ? settings.primaryColor : settings.textColor.withOpacity(0.6),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Downloaded Only',
                    style: TextStyle(
                      fontSize: 11,
                      color: origamiData.filterDownloadedOnly ? settings.textColor : settings.textColor.withOpacity(0.6),
                      fontWeight: origamiData.filterDownloadedOnly ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Clear filters button (Xóa Lọc)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isFilterActive ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !isFilterActive,
              child: TextButton.icon(
                onPressed: () {
                  origamiData.clearAllFilters();
                  _searchController.clear();
                },
                icon: const Icon(Icons.filter_alt_off, size: 14, color: Colors.redAccent),
                label: const Text(
                  'Xóa Lọc (Clear All Filters)',
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
    final categories = origamiData.allModels
        .expand((model) => model.categories)
        .toSet()
        .toList()
      ..sort();

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = origamiData.selectedCategories.contains(cat);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 4, bottom: 4),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : settings.textColor.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: settings.primaryColor,
              backgroundColor: settings.textColor.withOpacity(0.05),
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

  Widget _buildModelCard(BuildContext context, OrigamiModel model, AppSettingsProvider settings, OrigamiProvider origamiData) {
    final isDownloaded = origamiData.isModelDownloaded(model.id);

    return GestureDetector(
      onTap: () {
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
              settings.textColor.withOpacity(0.06),
              settings.textColor.withOpacity(0.01),
            ],
          ),
          border: Border.all(
            color: settings.textColor.withOpacity(0.08),
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
            // Model preview representation
            Expanded(
              child: Container(
                color: settings.textColor.withOpacity(0.02),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      model.assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.token, size: 40, color: settings.primaryColor);
                      },
                    ),
                    // Checkmark or cloud download state badge
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDownloaded ? Colors.greenAccent : Colors.white24,
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          isDownloaded ? Icons.offline_pin : Icons.cloud_download,
                          color: isDownloaded ? Colors.greenAccent : Colors.white70,
                          size: 13,
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: settings.textColor,
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
                      Text(
                        model.materials['paper_size'] ?? '15x15 cm',
                        style: TextStyle(
                          fontSize: 10,
                          color: settings.textColor.withOpacity(0.4),
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
          Icon(Icons.search_off, size: 50, color: settings.textColor.withOpacity(0.24)),
          const SizedBox(height: 12),
          Text(
            'No models found matching parameters',
            style: TextStyle(color: settings.textColor.withOpacity(0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsDrawer(AppSettingsProvider settings) {
    final List<String> fonts = ['Verdana', 'Courier New', 'Georgia'];
    final List<double> scales = [0.5, 0.75, 1.0, 1.25, 1.5];

    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: settings.backgroundColor.withOpacity(0.95),
        border: Border(
          left: BorderSide(color: settings.textColor.withOpacity(0.12), width: 1.0),
        ),
      ),
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: settings.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Visual Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: settings.textColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: settings.textColor.withOpacity(0.6), size: 20),
                    onPressed: () {
                      setState(() {
                        _isSettingsOpen = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // AppTheme Options
                  Text(
                    'Theme Presets',
                    style: TextStyle(fontSize: 11, color: settings.textColor.withOpacity(0.4), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppTheme.values.map((theme) {
                      final isSel = settings.activeTheme == theme;
                      return GestureDetector(
                        onTap: () => settings.setTheme(theme),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? settings.primaryColor : settings.textColor.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isSel ? settings.primaryColor : settings.textColor.withOpacity(0.12)),
                          ),
                          child: Text(
                            theme.name.replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? Colors.white : settings.textColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Typography Options
                  Text(
                    'Font Family',
                    style: TextStyle(fontSize: 11, color: settings.textColor.withOpacity(0.4), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: fonts.map((font) {
                      final isSel = settings.currentFont == font;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSel ? settings.primaryColor.withOpacity(0.1) : settings.textColor.withOpacity(0.03),
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
                              color: settings.textColor,
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

                  // Layout Scaling
                  Text(
                    'Global Zoom Scale',
                    style: TextStyle(fontSize: 11, color: settings.textColor.withOpacity(0.4), fontWeight: FontWeight.bold),
                  ),
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
                              color: isSel ? settings.primaryColor : settings.textColor.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$percent%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                color: isSel ? Colors.white : settings.textColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

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
}

class CustomGridBackground extends StatelessWidget {
  const CustomGridBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(color: Provider.of<AppSettingsProvider>(context).textColor.withOpacity(0.02)),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
