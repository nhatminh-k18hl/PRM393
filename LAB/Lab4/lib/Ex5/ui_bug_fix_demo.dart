import 'package:flutter/material.dart';

void main() {
  runApp(const DebugFixLayoutApp());
}

class DebugFixLayoutApp extends StatelessWidget {
  const DebugFixLayoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FixedLayoutScreen(),
    );
  }
}

class FixedLayoutScreen extends StatefulWidget {
  const FixedLayoutScreen({super.key});

  @override
  State<FixedLayoutScreen> createState() => _FixedLayoutScreenState();
}

class _FixedLayoutScreenState extends State<FixedLayoutScreen> {
  String _counterStatus = 'Chưa nhấn nút';
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 5: UI Debug & Fixes'),
        backgroundColor: Colors.redAccent,
      ),
      // [FIX LỖI 2]: Bọc nội dung bằng SingleChildScrollView để ngăn lỗi tràn màn hình (Overflow) khi phím ảo hiện lên hoặc màn nhỏ.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Màn Hình Đã Được Khắc Phục Lỗi Hệ Thống',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
              const SizedBox(height: 16),

              // Vùng hiển thị cập nhật trạng thái tương tác ứng dụng
              Text('Trạng thái tương tác: $_counterStatus (Số lần: $_counter)'),
              const SizedBox(height: 8),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                onPressed: () {
                  // [FIX LỖI 3]: Bọc logic trong hàm setState() để báo cho Flutter render lại dữ liệu mới lên UI
                  setState(() {
                    _counter++;
                    _counterStatus = 'Đang nhấn nút hoạt động';
                  });
                },
                child: const Text('Nhấn để cập nhật trạng thái'),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  // [FIX LỖI 4]: Gọi DatePicker sử dụng trực tiếp BuildContext hợp lệ từ widget tree hiện tại
                  await showDatePicker(
                    context: context, 
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                },
                child: const Text('Mở Lịch Chọn Ngày (DatePicker Safe)'),
              ),
              const SizedBox(height: 20),

              const Text('Danh sách phần tử cuộn nằm trong Column:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // [FIX LỖI 1]: Sử dụng SizedBox có kích thước chiều cao cố định (hoặc Expanded) để giới hạn không gian hiển thị cho ListView nằm trong Column, tránh lỗi trục trặc kích thước vô hạn (Vertical viewport infinity).
              SizedBox(
                height: 250, 
                child: ListView.builder(
                  shrinkWrap: true, // Hỗ trợ co dãn tối ưu diện tích
                  physics: const ClampingScrollPhysics(), // Đảm bảo cuộn mượt mà nội bộ
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text('Phần tử danh sách dòng số $index'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}