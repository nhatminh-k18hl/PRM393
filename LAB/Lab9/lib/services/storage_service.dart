import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class StorageService {
  static const String _fileName = 'local_database.json';

  // Hàm nội bộ tìm đường dẫn file lưu trữ ẩn trên ổ cứng thiết bị
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  // Hàm đọc dữ liệu toàn diện tích hợp cơ chế Persistence sao chép dữ liệu (Task 9.2)
  Future<List<Note>> loadNotes() async {
    try {
      final file = await _getLocalFile();

      // Nếu file đã tồn tại trong máy, đọc trực tiếp dữ liệu ra hiển thị
      if (await file.exists()) {
        final String fileContent = await file.readAsString();
        final List<dynamic> jsonList = json.decode(fileContent);
        return jsonList.map((item) => Note.fromJson(item)).toList();
      }

      // [KỊCH BẢN KHỞI CHẠY LẦN ĐẦU]: Đọc từ assets nạp vào máy (Task 9.1)
      final String assetContent =
          await rootBundle.loadString('assets/initial_notes.json');
      final List<dynamic> assetList = json.decode(assetContent);

      // Sao chép ghi đè xuống bộ nhớ thiết bị ngay lập tức để duy trì dữ liệu
      await file.writeAsString(assetContent);

      return assetList.map((item) => Note.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Hàm tự động lưu đè toàn bộ mảng đối tượng thành chuỗi JSON xuống File hệ thống
  Future<void> saveNotes(List<Note> notes) async {
    try {
      final file = await _getLocalFile();
      // Chuyển mảng đối tượng thành chuỗi string JSON qua jsonEncode
      final String jsonString =
          json.encode(notes.map((n) => n.toJson()).toList());
      await file
          .writeAsString(jsonString); // Thực thi lệnh ghi ổ cứng dữ liệu tĩnh
    } catch (_) {}
  }
}
