import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_data.dart';
import '../models/book_model.dart';
import '../services/preferences_service.dart';

// Vibe configuration for artistic immersive theme
class VibeConfig {
  final LinearGradient gradient;
  final String fontFamily;
  final Color textColor;
  final Color subTextColor;
  final Color cardColor;
  final Color primaryColor;

  VibeConfig({
    required this.gradient,
    required this.fontFamily,
    required this.textColor,
    required this.subTextColor,
    required this.cardColor,
    required this.primaryColor,
  });
}

// Global helper to resolve theme assets and configurations
VibeConfig getVibeConfig(int themeModeIndex, String lastReadBookId) {
  if (themeModeIndex == 0) {
    return VibeConfig(
      gradient: const LinearGradient(
        colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      fontFamily: 'Roboto',
      textColor: const Color(0xFF0F172A),
      subTextColor: Colors.black54,
      cardColor: Colors.white,
      primaryColor: Colors.blue,
    );
  } else if (themeModeIndex == 1) {
    return VibeConfig(
      gradient: const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF0D1117)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      fontFamily: 'Roboto',
      textColor: Colors.white,
      subTextColor: Colors.white70,
      cardColor: const Color(0xFF1E293B),
      primaryColor: const Color(0xFF00FFCC),
    );
  } else {
    // Immersive book synchronization theme
    if (lastReadBookId == '1') {
      return VibeConfig(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1E2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        fontFamily: 'Quicksand',
        textColor: Colors.white,
        subTextColor: Colors.white60,
        cardColor: const Color(0xFF1E293B).withOpacity(0.5),
        primaryColor: const Color(0xFF0284C7),
      );
    } else if (lastReadBookId == '2') {
      return VibeConfig(
        gradient: const LinearGradient(
          colors: [Color(0xFFFAF3E0), Color(0xFFFFFBEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        fontFamily: 'Merriweather',
        textColor: const Color(0xFF5C4033),
        subTextColor: const Color(0xFF8B7D6B),
        cardColor: Colors.white.withOpacity(0.7),
        primaryColor: const Color(0xFFEA580C),
      );
    } else if (lastReadBookId == '3') {
      return VibeConfig(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8ECE9), Color(0xFFF0F4F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        fontFamily: 'Lora',
        textColor: const Color(0xFF2C3E2B),
        subTextColor: const Color(0xFF6B7A68),
        cardColor: Colors.white.withOpacity(0.6),
        primaryColor: const Color(0xFF526E52),
      );
    } else {
      // Default fallback
      return VibeConfig(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        fontFamily: 'Roboto',
        textColor: const Color(0xFF0F172A),
        subTextColor: Colors.black54,
        cardColor: Colors.white,
        primaryColor: Colors.blue,
      );
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _selectedTags = [];

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _cycleTheme(PreferencesService settings) {
    final nextIndex = (settings.themeModeIndex + 1) % 3;
    settings.setThemeModeIndex(nextIndex);
    _showStatusMessage(nextIndex);
  }

  void _showStatusMessage(int index) {
    String msg = '';
    if (index == 0) {
      msg = "Đã chuyển sang: ☀️ Chế độ sáng";
    } else if (index == 1) {
      msg = "Đã chuyển sang: 🌙 Chế độ tối";
    } else {
      msg = "Đã chuyển sang: 📘 Đồng bộ với sách";
    }

    final settings = PreferencesService.instance;
    final vibe = getVibeConfig(index, settings.lastReadBookId);

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(fontWeight: FontWeight.bold, color: vibe.textColor),
        ),
        backgroundColor: vibe.cardColor.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1, milliseconds: 500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  IconData _getThemeIcon(int index) {
    if (index == 0) return Icons.light_mode;
    if (index == 1) return Icons.dark_mode;
    return Icons.book;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PreferencesService.instance,
      builder: (context, child) {
        final settings = PreferencesService.instance;
        final vibe =
            getVibeConfig(settings.themeModeIndex, settings.lastReadBookId);

        // Advanced Tag Intersection Filtering using every()
        final filteredBooks = mockBooks.where((book) {
          if (_selectedTags.isEmpty) return true;
          // Intersection: book must contain ALL of selected tags
          return _selectedTags.every((tag) => book.tags.contains(tag));
        }).toList();

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(gradient: vibe.gradient),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom Header / AppBar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thư Viện Tiểu Thuyết',
                            style: GoogleFonts.getFont(
                              vibe.fontFamily,
                              textStyle: TextStyle(
                                color: vibe.textColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          // Tri-State Theme Switch Button
                          IconButton(
                            icon: Icon(
                              _getThemeIcon(settings.themeModeIndex),
                              color: settings.themeModeIndex == 2
                                  ? const Color(0xFF00FFCC)
                                  : (settings.themeModeIndex == 1
                                      ? Colors.white
                                      : const Color(0xFF0F172A)),
                              size: 26,
                            ),
                            tooltip: 'Chuyển theme (Light/Dark/BookSync)',
                            onPressed: () => _cycleTheme(settings),
                          ),
                        ],
                      ),
                    ),

                    // Tag intersection filter section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Thể loại:',
                        style: GoogleFonts.getFont(
                          vibe.fontFamily,
                          textStyle: TextStyle(
                            color: vibe.textColor.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 48,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: allTags.length,
                        itemBuilder: (context, index) {
                          final tag = allTags[index];
                          final isSelected = _selectedTags.contains(tag);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              selectedColor: vibe.primaryColor.withOpacity(0.3),
                              checkmarkColor: vibe.textColor,
                              labelStyle: GoogleFonts.getFont(
                                vibe.fontFamily,
                                textStyle: TextStyle(
                                  color: isSelected
                                      ? vibe.textColor
                                      : vibe.textColor.withOpacity(0.7),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              backgroundColor: vibe.cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? vibe.primaryColor
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              onSelected: (selected) {
                                _toggleTag(tag);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    if (_selectedTags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đang lọc theo ${_selectedTags.length} thể loại giao nhau',
                              style: GoogleFonts.getFont(
                                vibe.fontFamily,
                                textStyle: TextStyle(
                                  color: vibe.primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTags.clear();
                                });
                              },
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              child: const Text(
                                'Xóa lọc',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Books list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: filteredBooks.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: vibe.cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 60, color: vibe.subTextColor),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Không tìm thấy truyện nào khớp với tất cả thể loại đã chọn!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.getFont(
                                      vibe.fontFamily,
                                      textStyle: TextStyle(
                                        color: vibe.textColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredBooks.length,
                              itemBuilder: (context, index) {
                                final book = filteredBooks[index];
                                return _buildBookCard(context, book, vibe);
                              },
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Live Demo Box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Cài Đặt Giao Diện Đọc Thử',
                        style: GoogleFonts.getFont(
                          vibe.fontFamily,
                          textStyle: TextStyle(
                            color: vibe.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: vibe.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: vibe.textColor.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Live Demo Box Container
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: settings.themeModeIndex == 0
                                    ? const Color(0xFFF1F5F9)
                                    : (settings.themeModeIndex == 1
                                        ? const Color(0xFF0F172A)
                                        : (settings.lastReadBookId == '1'
                                            ? const Color(0xFF0F172A)
                                            : vibe.gradient.colors.first)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: settings.themeModeIndex == 0
                                      ? Colors.black12
                                      : (settings.themeModeIndex == 1
                                          ? Colors.white10
                                          : vibe.textColor.withOpacity(0.12)),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aa Tổng quan giao diện',
                                    style: GoogleFonts.getFont(
                                      settings.currentFontFamily,
                                      textStyle: TextStyle(
                                        fontSize: settings.currentFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: settings.themeModeIndex == 0
                                            ? Colors.black
                                            : (settings.themeModeIndex == 1
                                                ? Colors.white
                                                : (settings.lastReadBookId ==
                                                        '1'
                                                    ? Colors.white
                                                    : vibe.textColor)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Văn bản đọc thử nghệ thuật: Trải nghiệm phông chữ văn học nạp động bằng Google Fonts.',
                                    style: GoogleFonts.getFont(
                                      settings.currentFontFamily,
                                      textStyle: TextStyle(
                                        fontSize: settings.currentFontSize - 2,
                                        color: settings.themeModeIndex == 0
                                            ? Colors.black87
                                            : (settings.themeModeIndex == 1
                                                ? Colors.white70
                                                : (settings.lastReadBookId ==
                                                        '1'
                                                    ? Colors.white70
                                                    : vibe.textColor
                                                        .withOpacity(0.85))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Slider Size
                            Row(
                              children: [
                                Text(
                                  'Cỡ chữ: ${settings.currentFontSize.toInt()}',
                                  style: GoogleFonts.getFont(
                                    vibe.fontFamily,
                                    textStyle: TextStyle(
                                      color: vibe.textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: settings.currentFontSize,
                                    min: 14.0,
                                    max: 30.0,
                                    activeColor: vibe.primaryColor,
                                    inactiveColor:
                                        vibe.textColor.withOpacity(0.12),
                                    onChanged: (value) {
                                      settings.setCurrentFontSize(value);
                                    },
                                  ),
                                ),
                              ],
                            ),

                            // Dropdown Font Family nạp động từ Google Fonts
                            Row(
                              children: [
                                Text(
                                  'Phông chữ: ',
                                  style: GoogleFonts.getFont(
                                    vibe.fontFamily,
                                    textStyle: TextStyle(
                                      color: vibe.textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: settings.currentFontFamily,
                                    dropdownColor: settings.themeModeIndex == 2
                                        ? (settings.lastReadBookId == '1'
                                            ? const Color(0xFF1E293B)
                                            : vibe.gradient.colors.first)
                                        : (settings.themeModeIndex == 1
                                            ? const Color(0xFF1E293B)
                                            : Colors.white),
                                    isExpanded: true,
                                    iconEnabledColor: vibe.textColor,
                                    style: GoogleFonts.getFont(
                                      settings.currentFontFamily,
                                      textStyle: TextStyle(
                                        color: settings.themeModeIndex == 2
                                            ? vibe.textColor
                                            : (settings.themeModeIndex == 1
                                                ? Colors.white
                                                : const Color(0xFF0F172A)),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    underline: Container(
                                      height: 1.5,
                                      color: vibe.primaryColor,
                                    ),
                                    items: <String>[
                                      'Lora',
                                      'Merriweather',
                                      'Quicksand',
                                      'Roboto',
                                      'Inter'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: GoogleFonts.getFont(
                                            value,
                                            textStyle: TextStyle(
                                              color: settings.themeModeIndex ==
                                                      2
                                                  ? vibe.textColor
                                                  : (settings.themeModeIndex ==
                                                          1
                                                      ? Colors.white
                                                      : const Color(
                                                          0xFF0F172A)),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        settings.setCurrentFontFamily(newValue);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, VibeConfig vibe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: vibe.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/detail',
              arguments: book,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover thumbnail
                Hero(
                  tag: 'book_cover_${book.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 90,
                      height: 130,
                      child: Image.asset(
                        book.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.blueGrey.shade100,
                            child: const Icon(Icons.book,
                                size: 40, color: Colors.blueGrey),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Book Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.getFont(
                          vibe.fontFamily,
                          textStyle: TextStyle(
                            color: vibe.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tác giả: ${book.author}',
                        style: GoogleFonts.getFont(
                          vibe.fontFamily,
                          textStyle: TextStyle(
                            color: vibe.subTextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.getFont(
                          vibe.fontFamily,
                          textStyle: TextStyle(
                            color: vibe.subTextColor,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tags list
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: book.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: vibe.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.getFont(
                                vibe.fontFamily,
                                textStyle: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: vibe.textColor.withOpacity(0.9),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
