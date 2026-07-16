import 'chapter_model.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String
  coverUrl; // Bạn có thể để link ảnh mạng hoặc chuỗi trống nếu dùng ảnh local
  final String description; // Tóm tắt tác phẩm
  final List<String>
  tags; // Danh sách tags thể loại: ["Thanh xuân", "Chữa lành"]
  final List<Chapter> chapters; // Danh sách các chương thuộc cuốn sách này

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.tags,
    required this.chapters,
  });
}
