import 'dart:async';

void main() {
  print('--- Exercise 4 – Stream Transformation ---');

  // Yêu cầu: Create a stream of numbers 1–5
  final Stream<int> baseStream = Stream.fromIterable([1, 2, 3, 4, 5]);

  print('Đang tiến hành thực hiện xử lý biến đổi chuỗi...');

  // Yêu cầu: Transform values to their squares using map() 
  // Yêu cầu: Filter even numbers with where()
  final Stream<int> transformedStream = baseStream
      .map((number) => number * number)         // Bình phương giá trị đầu vào (1, 4, 9, 16, 25)
      .where((squared) => squared.isEven);      // Lọc, chỉ lấy các kết quả chẵn (4, 16)

  // Yêu cầu: Listen and print each emitted value
  transformedStream.listen(
    (emittedValue) {
      print('Giá trị hợp lệ nhận được sau đường ống xử lý: $emittedValue');
    },
    onDone: () {
      print('Luồng Stream biến đổi dữ liệu hoàn thành.');
    },
  );
}