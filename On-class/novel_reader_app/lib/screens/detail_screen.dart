import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../services/preferences_service.dart';
import 'home_screen.dart' show getVibeConfig;

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get book from arguments
    final book = ModalRoute.of(context)!.settings.arguments as Book;

    return ListenableBuilder(
      listenable: PreferencesService.instance,
      builder: (context, child) {
        final settings = PreferencesService.instance;
        final vibe = getVibeConfig(settings.themeModeIndex, settings.lastReadBookId);

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(gradient: vibe.gradient),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App bar with hero cover thumbnail
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  stretch: true,
                  backgroundColor: vibe.cardColor,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: vibe.textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          book.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.blueGrey),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.black26,
                                Colors.black.withOpacity(0.85),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Text overlays on cover image
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Hero(
                                tag: 'book_cover_${book.id}',
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 100,
                                      height: 140,
                                      child: Image.asset(
                                        book.coverUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.blueGrey),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      book.title,
                                      style: GoogleFonts.getFont(
                                        vibe.fontFamily,
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Tác giả: ${book.author}',
                                      style: GoogleFonts.getFont(
                                        vibe.fontFamily,
                                        textStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: book.tags.map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: vibe.primaryColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            tag,
                                            style: GoogleFonts.getFont(
                                              vibe.fontFamily,
                                              textStyle: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
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
                      ],
                    ),
                  ),
                ),

                // Synopsis Summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tóm tắt tác phẩm',
                          style: GoogleFonts.getFont(
                            vibe.fontFamily,
                            textStyle: TextStyle(
                              color: vibe.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.description,
                          style: GoogleFonts.getFont(
                            vibe.fontFamily,
                            textStyle: TextStyle(
                              color: vibe.subTextColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                        Divider(height: 32, thickness: 1, color: vibe.textColor.withOpacity(0.08)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Danh sách chương (${book.chapters.length})',
                              style: GoogleFonts.getFont(
                                vibe.fontFamily,
                                textStyle: TextStyle(
                                  color: vibe.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Icon(Icons.format_list_bulleted, color: vibe.textColor),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Chapters list builder
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final Chapter chapter = book.chapters[index];
                      final isBookmarked = settings.isBookmarked(book.id, chapter.id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Card(
                          color: vibe.cardColor,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: vibe.textColor.withOpacity(0.04),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/reading',
                                arguments: {
                                  'book': book,
                                  'chapterIndex': index,
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isBookmarked
                                          ? vibe.primaryColor.withOpacity(0.2)
                                          : vibe.textColor.withOpacity(0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      chapter.isExtra ? Icons.star_rounded : Icons.menu_book,
                                      color: isBookmarked ? vibe.primaryColor : vibe.textColor.withOpacity(0.6),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chapter.displayInHeader,
                                          style: GoogleFonts.getFont(
                                            vibe.fontFamily,
                                            textStyle: TextStyle(
                                              color: vibe.textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          chapter.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.getFont(
                                            vibe.fontFamily,
                                            textStyle: TextStyle(
                                              color: vibe.subTextColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (isBookmarked)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8, right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: vibe.primaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.bookmark_added, size: 12, color: vibe.textColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Đang đọc',
                                            style: GoogleFonts.getFont(
                                              vibe.fontFamily,
                                              textStyle: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: vibe.textColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  Icon(Icons.arrow_forward_ios_rounded, color: vibe.textColor.withOpacity(0.2), size: 14),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: book.chapters.length,
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
