import 'package:flutter/material.dart';

void main() {
  runApp(const InputControlsApp());
}

class InputControlsApp extends StatelessWidget {
  const InputControlsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InputControlsDemo(),
    );
  }
}

class InputControlsDemo extends StatefulWidget {
  const InputControlsDemo({super.key});

  @override
  State<InputControlsDemo> createState() => _InputControlsDemoState();
}

class _InputControlsDemoState extends State<InputControlsDemo> {
  // Biến quản lý trạng thái (State) cho từng Widget điều khiển
  double _sliderValue = 20.0;
  bool _switchValue = true;
  String _selectedGender = 'Nam';
  DateTime? _selectedDate;

  // Hàm kích hoạt hộp thoại hiển thị DatePicker
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Cập nhật state để UI render lại ngày mới
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 2: Input Controls'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thành phần Slider (Thanh trượt giá trị)
            Text('1. Cấu hình âm lượng: ${_sliderValue.round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              activeColor: Colors.teal,
              onChanged: (value) {
                setState(() => _sliderValue = value);
              },
            ),
            const Divider(),

            // 2. Thành phần Switch (Nút gạt bật/tắt)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('2. Nhận thông báo hệ thống: ${_switchValue ? "BẬT" : "TẮT"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: _switchValue,
                  activeColor: Colors.teal,
                  onChanged: (value) {
                    setState(() => _switchValue = value);
                  },
                ),
              ],
            ),
            const Divider(),

            // 3. Nhóm RadioListTile (Chọn một giá trị duy nhất)
            const Text('3. Chọn giới tính của bạn:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Nam'),
              value: 'Nam',
              groupValue: _selectedGender,
              onChanged: (val) => setState(() => _selectedGender = val!),
            ),
            RadioListTile<String>(
              title: const Text('Nữ'),
              value: 'Nữ',
              groupValue: _selectedGender,
              onChanged: (val) => setState(() => _selectedGender = val!),
            ),
            const Divider(),

            // 4. Thành phần DatePicker (Bộ chọn ngày)
            const Text('4. Lựa chọn ngày sinh nhật:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Chọn ngày'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 16),
                Text(
                  _selectedDate == null 
                      ? 'Chưa có ngày được chọn' 
                      : 'Đã chọn: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}