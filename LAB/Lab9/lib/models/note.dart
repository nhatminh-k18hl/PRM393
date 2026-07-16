class Note {
  final int id;
  String title;
  String content;

  Note({
    required this.id,
    required this.title,
    required this.content,
  });

  // Chuyển từ Map JSON thô sang Object Dart
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }

  // Chuyển ngược từ Object Dart sang Map JSON để chuẩn bị ghi đè vào File hệ thống
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }
}
