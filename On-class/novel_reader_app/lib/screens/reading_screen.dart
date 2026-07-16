import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../models/paragraph_block.dart';
import '../services/preferences_service.dart';
import '../widgets/particle_background.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late Book _book;
  late int _currentChapterIndex;
  late ScrollController _scrollController;
  late Future<String> _futureContent;
  List<ParagraphBlock> _parsedParagraphs = [];

  bool _showToolbars = true;
  bool _showSettings = false;
  bool _showChapterDropdown = false;
  DateTime? _lastOverscrollTime;

  // Active paragraph tag inside Book 1
  String _activeParagraphVibe = 'NORMAL';

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _book = args['book'] as Book;
      _currentChapterIndex = args['chapterIndex'] as int;
      _scrollController = ScrollController();
      _scrollController.addListener(_onScroll);

      // Record this book ID dynamically to activate Vibe Spillover
      PreferencesService.instance.setLastReadBookId(_book.id);

      _loadChapterContent();
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChapterContent() {
    final chapter = _book.chapters[_currentChapterIndex];
    setState(() {
      _futureContent = chapter.loadContent();
      _activeParagraphVibe = 'NORMAL';
    });

    // Reset page scroll offsets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_book.id != '1') return; // RegExp vibe transitions apply to Book 1

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;

    if (maxScroll <= 0) return;
    if (_parsedParagraphs.isEmpty) return;

    // Viewport math estimation of active paragraph vibe
    final centerPosition = currentScroll + (viewportHeight / 2);
    final ratio = (centerPosition / (maxScroll + viewportHeight)).clamp(0.0, 1.0);
    final activeIndex = (ratio * _parsedParagraphs.length).floor().clamp(0, _parsedParagraphs.length - 1);

    final paragraphVibe = _parsedParagraphs[activeIndex].vibe;
    if (_activeParagraphVibe != paragraphVibe) {
      setState(() {
        _activeParagraphVibe = paragraphVibe;
      });
    }
  }

  void _goToPreviousChapter() {
    if (_currentChapterIndex > 0) {
      setState(() {
        _currentChapterIndex--;
        _showChapterDropdown = false;
        _showSettings = false;
      });
      _loadChapterContent();
      _showTemporaryStatus("Đã chuyển: ${_book.chapters[_currentChapterIndex].displayInHeader}");
    } else {
      _showTemporaryStatus("Đây là chương đầu tiên!");
    }
  }

  void _goToNextChapter() {
    if (_currentChapterIndex < _book.chapters.length - 1) {
      setState(() {
        _currentChapterIndex++;
        _showChapterDropdown = false;
        _showSettings = false;
      });
      _loadChapterContent();
      _showTemporaryStatus("Đã chuyển: ${_book.chapters[_currentChapterIndex].displayInHeader}");
    } else {
      _showTemporaryStatus("Bạn đã đọc hết truyện này!");
    }
  }

  void _handleOverscrollNext() {
    final now = DateTime.now();
    if (_lastOverscrollTime == null || now.difference(_lastOverscrollTime!) > const Duration(seconds: 2)) {
      _lastOverscrollTime = now;
      _goToNextChapter();
    }
  }

  void _toggleToolbars() {
    setState(() {
      _showToolbars = !_showToolbars;
    });
  }

  Map<String, Color> _getActiveThemeColors() {
    final settings = PreferencesService.instance;
    LinearGradient bgGradient;
    Color barColor;
    Color baseTextColor;
    if (settings.themeModeIndex == 0) {
      bgGradient = const LinearGradient(colors: [Color(0xFFFAF6EE), Color(0xFFF5F0E6)]);
      barColor = Colors.white;
      baseTextColor = const Color(0xFF1E293B);
    } else if (settings.themeModeIndex == 1) {
      bgGradient = const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF0F172A)]);
      barColor = const Color(0xFF1E293B);
      baseTextColor = const Color(0xFFE2E8F0);
    } else {
      if (_book.id == '1') {
        if (_activeParagraphVibe == 'PEACE') {
          bgGradient = const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E1E2E)]);
          baseTextColor = const Color(0xFF00FFCC);
        } else if (_activeParagraphVibe == 'HORROR') {
          bgGradient = const LinearGradient(colors: [Color(0xFF1E0A0A), Color(0xFF050000)]);
          baseTextColor = const Color(0xFFEF4444);
        } else {
          bgGradient = const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E1E2E)]);
          baseTextColor = Colors.white;
        }
      } else if (_book.id == '2') {
        bgGradient = const LinearGradient(colors: [Color(0xFFFAF3E0), Color(0xFFFFFBEB)]);
        baseTextColor = const Color(0xFF5C4033);
      } else {
        bgGradient = const LinearGradient(colors: [Color(0xFFE8ECE9), Color(0xFFF0F4F1)]);
        baseTextColor = const Color(0xFF2C3E2B);
      }
      barColor = bgGradient.colors.first;
    }
    return {
      'barColor': barColor,
      'baseTextColor': baseTextColor,
    };
  }

  void _showTemporaryStatus(String message) {
    final colors = _getActiveThemeColors();
    final barColor = colors['barColor']!;
    final baseTextColor = colors['baseTextColor']!;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontWeight: FontWeight.bold, color: baseTextColor),
        ),
        backgroundColor: barColor.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(bottom: 90, left: 24, right: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Chapter chapter = _book.chapters[_currentChapterIndex];

    return ListenableBuilder(
      listenable: PreferencesService.instance,
      builder: (context, child) {
        final settings = PreferencesService.instance;

        // Dynamic theme styling resolver
        LinearGradient bgGradient;
        String activeFontFamily = settings.currentFontFamily;
        Color barColor;
        Color controlIconColor;
        Color primaryColor;
        String particleVibeType = 'SPARKS';

        Color baseTextColor;
        List<Color> textGradientColors;

        if (settings.themeModeIndex == 0) {
          // Light Mode
          bgGradient = const LinearGradient(colors: [Color(0xFFFAF6EE), Color(0xFFF5F0E6)]);
          barColor = Colors.white.withOpacity(0.9);
          controlIconColor = const Color(0xFF334155);
          baseTextColor = const Color(0xFF1E293B);
          textGradientColors = [const Color(0xFF1E293B), const Color(0xFF334155)];
          primaryColor = Colors.blue;
        } else if (settings.themeModeIndex == 1) {
          // Dark Mode
          bgGradient = const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF0F172A)]);
          barColor = const Color(0xFF1E293B).withOpacity(0.9);
          controlIconColor = Colors.white70;
          baseTextColor = const Color(0xFFE2E8F0);
          textGradientColors = [const Color(0xFFE2E8F0), const Color(0xFF94A3B8)];
          primaryColor = const Color(0xFF00FFCC);
        } else {
          // Immersive Book Sync
          if (_book.id == '1') {
            primaryColor = const Color(0xFF0284C7);
            if (_activeParagraphVibe == 'PEACE') {
              bgGradient = const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E1E2E)]);
              particleVibeType = 'BUBBLES';
              baseTextColor = const Color(0xFF00FFCC);
              textGradientColors = [const Color(0xFF00FFCC), const Color(0xFF00E5FF)];
            } else if (_activeParagraphVibe == 'HORROR') {
              bgGradient = const LinearGradient(colors: [Color(0xFF1E0A0A), Color(0xFF050000)]);
              particleVibeType = 'HORROR_ASH';
              baseTextColor = const Color(0xFFEF4444);
              textGradientColors = [const Color(0xFFEF4444), const Color(0xFF7F1D1D)];
            } else {
              bgGradient = const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E1E2E)]);
              particleVibeType = 'SPARKS';
              baseTextColor = Colors.white;
              textGradientColors = [const Color(0xFFE0F2FE), const Color(0xFF0284C7)];
            }
          } else if (_book.id == '2') {
            bgGradient = const LinearGradient(colors: [Color(0xFFFAF3E0), Color(0xFFFFFBEB)]);
            baseTextColor = const Color(0xFF5C4033);
            textGradientColors = [const Color(0xFF5C4033), const Color(0xFF8B7D6B)];
            primaryColor = const Color(0xFFEA580C);
            particleVibeType = 'LEAVES';
          } else {
            bgGradient = const LinearGradient(colors: [Color(0xFFE8ECE9), Color(0xFFF0F4F1)]);
            baseTextColor = const Color(0xFF2C3E2B);
            textGradientColors = [const Color(0xFF4B5563), const Color(0xFF1E3A1E)];
            primaryColor = const Color(0xFF526E52);
            particleVibeType = 'SWALLOWS';
          }
          barColor = bgGradient.colors.first.withOpacity(0.95);
          controlIconColor = baseTextColor;
        }

        return Scaffold(
          body: Stack(
            children: [
              // Layer 1: Background Gradient Adaptable Container
              Positioned.fill(
                child: Container(decoration: BoxDecoration(gradient: bgGradient)),
              ),

              // Layer 2: Math-Driven CustomPainter Particles & Watermark overlays chìm
              if (settings.themeModeIndex == 2)
                Positioned.fill(
                  child: ParticleBackground(vibeType: particleVibeType),
                ),

              // Layer 3: Reading Canvas (Text and scroll content)
              Positioned.fill(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is ScrollUpdateNotification) {
                      final delta = notification.scrollDelta;
                      if (delta != null && delta != 0) {
                        if (delta > 0 && _showToolbars && !_showSettings && !_showChapterDropdown) {
                          setState(() {
                            _showToolbars = false;
                          });
                        } else if (delta < 0 && !_showToolbars) {
                          setState(() {
                            _showToolbars = true;
                          });
                        }
                      }
                    }

                    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent && !_showToolbars) {
                      setState(() {
                        _showToolbars = true;
                      });
                    }

                    if (notification is OverscrollNotification) {
                      if (notification.overscroll > 0.0) {
                        _handleOverscrollNext();
                      }
                    }
                    return false;
                  },
                  child: GestureDetector(
                    onTapUp: (details) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final dx = details.localPosition.dx;
                      if (dx < screenWidth * 0.15) {
                        _goToPreviousChapter();
                      } else if (dx > screenWidth * 0.85) {
                        _goToNextChapter();
                      } else {
                        _toggleToolbars();
                      }
                    },
                    child: FutureBuilder<String>(
                      future: _futureContent,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(color: primaryColor),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Lỗi tải nội dung: ${snapshot.error}',
                                style: GoogleFonts.getFont(
                                  activeFontFamily,
                                  textStyle: TextStyle(color: baseTextColor, fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        }

                        // Determine content layout presentation
                        if (_book.id == '2' && _currentChapterIndex >= 3) {
                          return _buildArtisticEndState(context, activeFontFamily, baseTextColor, primaryColor);
                        }

                        if (_book.id == '3') {
                          return _buildElegantEmptyState(context, activeFontFamily, baseTextColor, primaryColor);
                        }

                        final rawText = snapshot.data ?? '';
                        _parsedParagraphs = chapter.parseParagraphs(rawText);

                        return SizedBox.expand(
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              20,
                              MediaQuery.of(context).padding.top + 76,
                              20,
                              MediaQuery.of(context).padding.bottom + 96,
                            ),
                            itemCount: _parsedParagraphs.length + 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // Title Header
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: Text(
                                    chapter.displayInDropList,
                                    style: GoogleFonts.getFont(
                                      activeFontFamily,
                                      textStyle: TextStyle(
                                        fontSize: settings.currentFontSize + 4,
                                        fontWeight: FontWeight.bold,
                                        color: baseTextColor,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (index == _parsedParagraphs.length + 1) {
                                // End boundary
                                return Padding(
                                  padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
                                  child: Center(
                                    child: Text(
                                      '••• HẾT CHƯƠNG •••',
                                      style: GoogleFonts.getFont(
                                        activeFontFamily,
                                        textStyle: TextStyle(
                                          color: baseTextColor.withOpacity(0.3),
                                          letterSpacing: 2,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final block = _parsedParagraphs[index - 1];

                              // Apply Drop Cap for the first paragraph
                              if (index == 1 && block.text.isNotEmpty) {
                                final firstChar = block.text.substring(0, 1);
                                final restText = block.text.substring(1);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        firstChar,
                                        style: GoogleFonts.getFont(
                                          activeFontFamily,
                                          textStyle: TextStyle(
                                            fontSize: settings.currentFontSize * 2.6,
                                            fontWeight: FontWeight.w900,
                                            color: primaryColor,
                                            height: 0.9,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ShaderMask(
                                          shaderCallback: (bounds) {
                                            return LinearGradient(
                                              colors: textGradientColors,
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ).createShader(bounds);
                                          },
                                          blendMode: BlendMode.srcIn,
                                          child: Text(
                                            restText,
                                            style: GoogleFonts.getFont(
                                              activeFontFamily,
                                              textStyle: TextStyle(
                                                fontSize: settings.currentFontSize,
                                                height: 1.65,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Standard paragraph wrapped in ShaderMask to blend gradient colors
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: textGradientColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcIn,
                                  child: Text(
                                    block.text,
                                    style: GoogleFonts.getFont(
                                      activeFontFamily,
                                      textStyle: TextStyle(
                                        fontSize: settings.currentFontSize,
                                        height: 1.65,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Layer 4: Header (Fixed top, sliding out)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                top: _showToolbars ? 0 : -100,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: barColor,
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new, color: controlIconColor),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _book.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.getFont(
                                    activeFontFamily,
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: controlIconColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  chapter.displayInHeader,
                                  style: GoogleFonts.getFont(
                                    activeFontFamily,
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      color: controlIconColor.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, color: controlIconColor),
                            onPressed: () {
                              setState(() {
                                _showSettings = !_showSettings;
                                _showChapterDropdown = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Layer 4: Footer (Fixed bottom, sliding out)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                bottom: _showToolbars ? 0 : -100,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: barColor,
                      padding: EdgeInsets.only(
                        top: 8,
                        bottom: MediaQuery.of(context).padding.bottom + 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.home_rounded, color: controlIconColor),
                            onPressed: () {
                              Navigator.popUntil(context, ModalRoute.withName('/home'));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_previous_rounded, color: controlIconColor),
                            onPressed: _goToPreviousChapter,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _showChapterDropdown = !_showChapterDropdown;
                                _showSettings = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: controlIconColor.withOpacity(0.3),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    chapter.displayInHeader,
                                    style: GoogleFonts.getFont(
                                      activeFontFamily,
                                      textStyle: TextStyle(
                                        color: controlIconColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_drop_down, color: controlIconColor, size: 18),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next_rounded, color: controlIconColor),
                            onPressed: _goToNextChapter,
                          ),
                          IconButton(
                            icon: Icon(
                              settings.isBookmarked(_book.id, chapter.id)
                                  ? Icons.bookmark_added_rounded
                                  : Icons.bookmark_border_rounded,
                              color: settings.isBookmarked(_book.id, chapter.id)
                                  ? const Color(0xFF00E5FF)
                                  : controlIconColor,
                            ),
                            onPressed: () {
                              settings.toggleBookmark(_book.id, chapter.id);
                              _showTemporaryStatus(
                                settings.isBookmarked(_book.id, chapter.id)
                                    ? "Đã lưu Bookmark chương!"
                                    : "Đã gỡ Bookmark chương này.",
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Layer 5: Blurry Settings Overlay Panel
              if (_showSettings)
                _buildSettingsOverlay(context, settings, activeFontFamily, baseTextColor, barColor, primaryColor),

              // Layer 5: Chapter Dropdown List Overlay (Floating list menu)
              if (_showChapterDropdown)
                _buildChapterDropdownOverlay(context, settings, barColor, baseTextColor, primaryColor, activeFontFamily),
            ],
          ),
        );
      },
    );
  }

  // settings configurations overlay
  Widget _buildSettingsOverlay(
      BuildContext context, PreferencesService settings, String fontFamily, Color textColor, Color barColor, Color primaryColor) {
    final cardBgColor = settings.themeModeIndex == 2
        ? barColor.withOpacity(1.0)
        : (settings.themeModeIndex == 0 ? Colors.white : const Color(0xFF1E293B));

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showSettings = false;
              });
            },
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60,
                left: 16,
                right: 16,
              ),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CÀI ĐẶT GIAO DIỆN ĐỌC',
                        style: GoogleFonts.getFont(
                          fontFamily,
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: settings.themeModeIndex == 2
                                ? primaryColor
                                : (settings.themeModeIndex == 0 ? Colors.blue : const Color(0xFF00FFCC)),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: 18,
                        color: textColor.withOpacity(0.8),
                        onPressed: () => setState(() => _showSettings = false),
                      ),
                    ],
                  ),
                  Divider(height: 12, color: textColor.withOpacity(0.12)),

                  // Tri-State Mode Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chế độ giao diện:',
                          style: GoogleFonts.getFont(
                            fontFamily,
                            textStyle: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildThemeChoiceChip(settings, 0, 'Sáng', Icons.light_mode),
                            _buildThemeChoiceChip(settings, 1, 'Tối', Icons.dark_mode),
                            _buildThemeChoiceChip(settings, 2, 'Đồng bộ với sách', Icons.book),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Slider size adjust
                  Row(
                    children: [
                      Text(
                        'Cỡ chữ: ${settings.currentFontSize.toInt()}',
                        style: GoogleFonts.getFont(
                          fontFamily,
                          textStyle: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: settings.currentFontSize,
                          min: 14.0,
                          max: 30.0,
                          activeColor: primaryColor,
                          inactiveColor: textColor.withOpacity(0.15),
                          onChanged: (value) {
                            settings.setCurrentFontSize(value);
                          },
                        ),
                      ),
                    ],
                  ),

                  // Font Family Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phông chữ:',
                        style: GoogleFonts.getFont(
                          fontFamily,
                          textStyle: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: DropdownButton<String>(
                          value: settings.currentFontFamily,
                          dropdownColor: cardBgColor,
                          isExpanded: true,
                          style: GoogleFonts.getFont(
                            settings.currentFontFamily,
                            textStyle: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          underline: Container(
                            height: 1,
                            color: primaryColor,
                          ),
                          items: <String>['Lora', 'Merriweather', 'Quicksand', 'Roboto', 'Inter']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: GoogleFonts.getFont(value)),
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
        ],
      ),
    );
  }

  Widget _buildThemeChoiceChip(PreferencesService settings, int index, String label, IconData icon) {
    final isSelected = settings.themeModeIndex == index;
    return ChoiceChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          settings.setThemeModeIndex(index);
        }
      },
    );
  }

  // Floating selector dropdown overlays
  Widget _buildChapterDropdownOverlay(
      BuildContext context, PreferencesService settings, Color barColor, Color textColor, Color primaryColor, String fontFamily) {
    final cardBgColor = settings.themeModeIndex == 2
        ? barColor.withOpacity(1.0)
        : (settings.themeModeIndex == 1 ? const Color(0xFF1E293B) : Colors.white);

    final titleColor = settings.themeModeIndex == 2
        ? primaryColor
        : (settings.themeModeIndex == 1 ? const Color(0xFF00FFCC) : Colors.blue);

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showChapterDropdown = false;
              });
            },
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MỤC LỤC CHƯƠNG',
                          style: GoogleFonts.getFont(
                            fontFamily,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: titleColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          iconSize: 18,
                          color: textColor.withOpacity(0.6),
                          onPressed: () => setState(() => _showChapterDropdown = false),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: textColor.withOpacity(0.12)),

                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _book.chapters.length,
                      itemBuilder: (context, index) {
                        final Chapter chapter = _book.chapters[index];
                        final isCurrent = index == _currentChapterIndex;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (isCurrent) {
                                setState(() {
                                  _showChapterDropdown = false;
                                });
                              } else {
                                setState(() {
                                  _currentChapterIndex = index;
                                  _showChapterDropdown = false;
                                });
                                _loadChapterContent();
                              }
                            },
                            child: Container(
                              color: isCurrent
                                  ? primaryColor.withOpacity(0.12)
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Icon(
                                    isCurrent
                                        ? Icons.play_arrow_rounded
                                        : (chapter.isExtra ? Icons.star_rounded : Icons.menu_book),
                                    size: 16,
                                    color: isCurrent
                                        ? primaryColor
                                        : textColor.withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      chapter.displayInDropList,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.getFont(
                                        fontFamily,
                                        textStyle: TextStyle(
                                          color: isCurrent
                                              ? primaryColor
                                              : textColor.withOpacity(0.8),
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isCurrent)
                                    Text(
                                      'ĐANG ĐỌC',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Artistic End-State Canvas (Book 2 index >= 3)
  Widget _buildArtisticEndState(BuildContext context, String fontFamily, Color textColor, Color primaryColor) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.palette_outlined, size: 64, color: primaryColor),
            const SizedBox(height: 24),
            Text(
              'Dưới bóng ngô đồng già, câu chuyện tạm thời dừng lại tại đây...',
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                fontFamily,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Độc giả vui lòng chờ chương tiếp theo!',
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                fontFamily,
                textStyle: TextStyle(
                  fontSize: 13,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              },
              icon: const Icon(Icons.home, size: 18),
              label: const Text('Quay lại Thư Viện'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Elegant Empty State Page (Book 3)
  Widget _buildElegantEmptyState(BuildContext context, String fontFamily, Color textColor, Color primaryColor) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_outline, size: 64, color: primaryColor),
            const SizedBox(height: 24),
            Text(
              'Nơi bến đỗ bình an đang được tạo tác, Đường Hà Thanh và Chu Hải Yến sẽ sớm hội ngộ cùng độc giả!',
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                fontFamily,
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              },
              icon: const Icon(Icons.home, size: 18),
              label: const Text('Quay lại Thư Viện'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
