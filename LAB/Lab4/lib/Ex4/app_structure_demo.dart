import 'package:flutter/material.dart';

void main() {
  runApp(const CompleteAppStructure());
}

class CompleteAppStructure extends StatefulWidget {
  const CompleteAppStructure({super.key});

  @override
  State<CompleteAppStructure> createState() => _CompleteAppStructureState();
}

class _CompleteAppStructureState extends State<CompleteAppStructure> {
  // Trạng thái lưu trữ việc bật/tắt chế độ màn hình Tối (Dark mode)
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exercise 4: App Structure',
      
      // 1. Cấu hình Theme Sáng (Light Theme)
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      
      // 2. Cấu hình Theme Tối (Dark Theme)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
      ),
      
      // Điều khiển việc áp dụng theme dựa trên giá trị biến boolean trạng thái
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      home: Scaffold(
        // Thanh ứng dụng AppBar
        appBar: AppBar(
          title: const Text('Giao Diện Chuẩn Scaffold & Theme'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                // Đảo ngược trạng thái màn hình khi nhấn nút điều khiển
                setState(() => _isDarkMode = !_isDarkMode);
              },
            )
          ],
        ),
        
        // Vùng hiển thị trung tâm nội dung Body
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                size: 80,
                color: _isDarkMode ? Colors.amber : Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                _isDarkMode ? 'Chế độ hiển thị: DARK MODE' : 'Chế độ hiển thị: LIGHT MODE',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Hãy nhấn nút trên AppBar để đổi Theme hoặc FAB để tạo mới'),
            ],
          ),
        ),
        
        // Nút hành động nổi FloatingActionButton (FAB)
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hành động FAB: Đang xử lý tạo mới tệp dữ liệu!')),
            );
          },
          tooltip: 'Thêm mới dữ liệu',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}