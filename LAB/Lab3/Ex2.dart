import 'dart:convert';

// Yêu cầu: Create User { name, email } and User.fromJson(Map) constructor
class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  // Constructor giải mã Map thành Object
  User.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      email = json['email'] as String;

  @override
  String toString() => 'User(name: $name, email: $email)';
}

class UserRepository {
  // Yêu cầu: Simulate JSON list from an API
  final String _mockApiResponse = '''
  [
    {"name": "Nguyen Nhat Minh", "email": "minhnnhe186934@fpt.edu.vn"},
    {"name": "Tran Thi B", "email": "btt@fpt.edu.vn"}
  ]
  ''';

  // Yêu cầu: Use Future<List<User>> to return parsed data
  Future<List<User>> fetchUsers() async {
    await Future.delayed(Duration(milliseconds: 500)); // Giả lập độ trễ mạng

    // Giải mã chuỗi chuỗi JSON thô
    final List<dynamic> parsedJson =
        jsonDecode(_mockApiResponse) as List<dynamic>;

    // Ánh xạ thành mảng các đối tượng User dữ liệu sạch
    return parsedJson
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

void main() async {
  print('--- Exercise 2 – User Repository with JSON ---');
  final userRepo = UserRepository();

  print('Đang tải danh sách người dùng từ API...');
  // Yêu cầu: Display results with print()
  List<User> users = await userRepo.fetchUsers();
  print('Kết quả danh sách User sau bóc tách:');
  for (var user in users) {
    print('Tên: ${user.name} | Email: ${user.email}');
  }
}
