import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  // Đường dẫn Endpoint tĩnh do đề bài quy định
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  // [REQ LAB 8.1]: Hàm thực hiện phương thức GET lấy danh sách bài viết bất đồng bộ
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // Giải mã chuỗi string nhận được thành mảng dữ liệu thô
        final List<dynamic> rawData = json.decode(response.body);
        // Áp dụng hàm factory biến đổi map thành List<Post> chuẩn xác
        return rawData.map((jsonItem) => Post.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Server phản hồi mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      // Bẫy lỗi ngoại lệ nếu mất internet hoặc sai URL mạng
      throw Exception(
          'Không thể kết nối Internet hoặc Server sập! Chi tiết: $e');
    }
  }

  // [BONUS FEATURE]: Hàm thực hiện phương thức POST đẩy dữ liệu Form lên Server
  Future<bool> createPost(String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'title': title,
          'body': body,
          'userId': 1,
        }),
      );
      // Mã 201 đại diện cho trạng thái tạo tài nguyên mới thành công
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
