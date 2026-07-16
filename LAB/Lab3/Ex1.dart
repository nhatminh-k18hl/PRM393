import 'dart:async';

// Yêu cầu: Define Product { id, name, price }
class Product {
  final int id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  @override
  String toString() => 'Product(id: $id, name: $name, price: \$$price)';
}

// Yêu cầu: Implement ProductRepository
class ProductRepository {
  // Yêu cầu: Use StreamController.broadcast() to emit new items
  final StreamController<Product> _controller =
      StreamController<Product>.broadcast();

  // Yêu cầu: Future<List<Product>> getAll()
  Future<List<Product>> getAll() async {
    await Future.delayed(Duration(milliseconds: 500)); // Giả lập độ trễ ngắn
    return [
      Product(id: 101, name: 'Laptop Dell', price: 999.99),
      Product(id: 102, name: 'iPhone 15', price: 799.00),
    ];
  }

  // Yêu cầu: Stream<Product> liveAdded() for real-time updates
  Stream<Product> liveAdded() {
    return _controller.stream;
  }

  // Hàm phụ trợ để đẩy phần tử mới vào stream
  void emitNewProduct(Product product) {
    _controller.add(product);
  }

  void dispose() {
    _controller.close();
  }
}

void main() async {
  print('--- Exercise 1 – Product Model & Repository ---');
  final repo = ProductRepository();

  // Đăng ký lắng nghe sự kiện thời gian thực từ liveAdded() stream
  repo.liveAdded().listen((product) {
    print('Live Stream Nhận Thêm Sản Phẩm: $product');
  });

  // Gọi phương thức getAll() để in danh sách cố định
  print('Đang tải toàn bộ sản phẩm cố định từ getAll()...');
  final products = await repo.getAll();
  print('Kết quả getAll(): $products\n');

  // Đẩy phần tử mới vào stream để kiểm tra kết quả in ra màn hình
  print('Đang emit các sản phẩm mới theo thời gian thực...');
  repo.emitNewProduct(Product(id: 103, name: 'Chuột Logitech', price: 25.50));
  repo.emitNewProduct(Product(id: 104, name: 'Bàn phím cơ', price: 85.00));

  await Future.delayed(Duration(milliseconds: 100));
  repo.dispose();
}
