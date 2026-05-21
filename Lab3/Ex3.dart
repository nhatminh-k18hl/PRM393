import 'dart:async';

void main() {
  print('--- Exercise 3 – Async + Microtask Debugging ---');

  // In dòng thông báo ban đầu (Mã đồng bộ - Synchronous)
  print('Trạng thái: Khởi chạy hàm main() đồng bộ.');

  // Yêu cầu: Snippet với Future(() {}) đại diện cho EVENT QUEUE
  Future(() {
    print('Kết quả: Callback của [EVENT QUEUE] khởi chạy.');
  });

  // Yêu cầu: Snippet với scheduleMicrotask() đại diện cho MICROTASK QUEUE
  scheduleMicrotask(() {
    print('Kết quả: Callback của [MICROTASK QUEUE] khởi chạy.');
  });

  print('Trạng thái: Kết thúc hàm main() đồng bộ.\n');
}
