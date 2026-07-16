import 'package:flutter/services.dart' show rootBundle;
import 'paragraph_block.dart';

class Chapter {
  final String id;
  final int number; // Số chương
  final String name; // Tên chương riêng lẻ
  final String txtPath; // Đường dẫn file .txt
  final bool isExtra; // Đánh dấu ngoại truyện

  Chapter({
    required this.id,
    required this.number,
    required this.name,
    required this.txtPath,
    this.isExtra = false,
  });

  // Defensive loading with double path spelling resolution
  Future<String> loadContent() async {
    try {
      String path = txtPath;
      String content;
      try {
        content = await rootBundle.loadString(path);
      } catch (_) {
        // Path variation resolver: handles mismatches between ngo-dong-chuong- and ngo-ngo-dong-chuong-
        if (path.contains('ngo-dong-chuong-')) {
          path = path.replaceAll('ngo-dong-chuong-', 'ngo-ngo-dong-chuong-');
        } else if (path.contains('ngo-ngo-dong-chuong-')) {
          path = path.replaceAll('ngo-ngo-dong-chuong-', 'ngo-dong-chuong-');
        }
        content = await rootBundle.loadString(path);
      }
      
      if (content.trim().isEmpty) {
        return "Nội dung chương này đang được cập nhật, độc giả vui lòng quay lại sau!";
      }
      return content;
    } catch (e) {
      return "Nội dung chương này đang được cập nhật, độc giả vui lòng quay lại sau!";
    }
  }

  // RegExp parser bóc tách thẻ lệnh [THEME:X]
  List<ParagraphBlock> parseParagraphs(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    final List<ParagraphBlock> blocks = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      final regExp = RegExp(r'^\[THEME:(PEACE|HORROR)\](.*)$');
      final match = regExp.firstMatch(line);

      if (match != null) {
        final vibe = match.group(1)!;
        final text = match.group(2)!.trim();
        blocks.add(ParagraphBlock(text: text, vibe: vibe));
      } else {
        blocks.add(ParagraphBlock(text: line, vibe: 'NORMAL'));
      }
    }

    if (blocks.isEmpty) {
      blocks.add(ParagraphBlock(
        text: "Nội dung chương này đang được cập nhật, độc giả vui lòng quay lại sau!",
        vibe: 'NORMAL',
      ));
    }

    return blocks;
  }

  String get displayInHeader =>
      isExtra ? "Ngoại truyện $number" : "Chương $number";
  String get displayInDropList =>
      isExtra ? "Ngoại truyện $number: $name" : "Chương $number: $name";
}
