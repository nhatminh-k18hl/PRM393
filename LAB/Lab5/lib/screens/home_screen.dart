import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../data/sample_data.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _filteredMovies = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredMovies =
        sampleMovies; // Gán danh sách phim ban đầu chuẩn xác tại vòng đời initState
  }

  void _runSearchFilter(String keyword) {
    setState(() {
      _filteredMovies = sampleMovies
          .where((movie) =>
              movie.title.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 Movie World Portfolio',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Khối Thanh tìm kiếm phim
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _runSearchFilter,
              decoration: InputDecoration(
                hintText: 'Nhập tên bộ phim cần tìm...',
                prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 2),
                ),
              ),
            ),
          ),

          // Khối render danh sách phim
          Expanded(
            child: _filteredMovies.isEmpty
                ? const Center(
                    child: Text('Không có kết quả phim nào trùng khớp!',
                        style: TextStyle(fontSize: 16, color: Colors.grey)))
                : ListView.builder(
                    itemCount: _filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = _filteredMovies[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        // [FIX LỖI BẤM ĐIỀU HƯỚNG]: Đặt InkWell bọc ra phía ngoài cùng của toàn bộ cấu trúc Row nội dung thẻ
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailScreen(movie: movie),
                              ),
                            );
                          },
                          // Toàn bộ giao diện hiển thị nằm trọn vẹn trong child của InkWell, giúp bấm vào đâu cũng ăn điều hướng
                          child: Row(
                            children: [
                              // Khối ảnh Poster bên trái có tích hợp cơ chế phòng vệ lỗi mạng (Error Handling Image)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                ),
                                child: Image.network(
                                  movie.posterUrl,
                                  width: 100,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  // [FIX LỖI HIỂN THỊ ẢNH]: Cơ chế hiển thị vòng xoay tiến trình khi ảnh đang tải
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 100,
                                      height: 140,
                                      color: Colors.grey[200],
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                    );
                                  },
                                  // [FIX LỖI HIỂN THỊ ẢNH]: Nếu link die hoặc mất mạng, tự động đổi sang icon thay thế, không bị sập UI
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 140,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                          Icons.movie_creation_outlined,
                                          size: 40,
                                          color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              // Khối thông tin Text mô tả bên phải
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        maxLines:
                                            2, // Cho phép hiển thị tối đa 2 dòng chữ
                                        overflow: TextOverflow
                                            .ellipsis, // Nếu quá dài tự động thêm dấu ...
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber, size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${movie.rating} / 10',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 12.0),
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
