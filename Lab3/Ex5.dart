// Yêu cầu: Create a Settings class with private constructor
class Settings {
  final String theme;
  final bool enableNotifications;

  // Static private cache variable để lưu trữ thực thể đệm
  static Settings? _cacheInstance;

  // Private constructor (sử dụng dấu gạch dưới) ngăn chặn khởi tạo tự do từ ngoài
  Settings._privateConstructor({required this.theme, required this.enableNotifications});

  // Yêu cầu: Add a factory Settings() that returns a singleton instance
  factory Settings({String theme = 'Dark', bool enableNotifications = true}) {
    // Cơ chế Caching: Nếu chưa có instance trong bộ nhớ cache thì tiến hành tạo mới
    _cacheInstance ??= Settings._privateConstructor(
      theme: theme,
      enableNotifications: enableNotifications,
    );
    // Trả về thực thể duy nhất từ cache ngầm
    return _cacheInstance!;
  }
}

void main() {
  print('--- Exercise 5 – Factory Constructors & Cache ---');

  // Khởi tạo thực thể cấu hình A
  Settings a = Settings(theme: 'Light', enableNotifications: false);
  print('Instance a -> Theme: ${a.theme}');

  // Khởi tạo thực thể cấu hình B (Thuộc tính mới truyền vào sẽ bị bỏ qua vì đã lấy từ cache cũ ra)
  Settings b = Settings(theme: 'Dark', enableNotifications: true);
  print('Instance b -> Theme: ${b.theme}');

  // Yêu cầu: Verify two instances refer to the same object (identical(a, b) → true)
  bool isSameObject = identical(a, b);
  
  print('\n Kết quả xác minh tính đồng nhất Singleton Pattern:');
  print('-> Trạng thái kiểm tra identical(a, b): $isSameObject'); // Sẽ in ra: true
}