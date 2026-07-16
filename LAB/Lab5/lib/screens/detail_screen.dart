import 'package:flutter/material.dart';
import '../models/movie.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Biến quản lý trạng thái nút Yêu thích (Optional Enhancement)
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(
            color: Colors.white), // Đổi màu nút Back mặc định sang trắng
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO BANNER SECTION: Sử dụng Stack phủ màu mờ đen điện ảnh (Gradient Overlay)
            Stack(
              children: [
                Image.network(
                  movie.backdropUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.85),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. GENRES SECTION: Sử dụng Wrap xếp dải nhãn chống lỗi tràn hàng ngang
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: movie.genres.map((g) {
                      return Chip(
                        label: Text(g,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 3. ROW OF ICON BUTTONS: Hàng nút tương tác phản hồi SnackBar linh hoạt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(_isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border),
                        color: _isFavorite ? Colors.red : Colors.grey,
                        iconSize: 32,
                        onPressed: () {
                          setState(() => _isFavorite =
                              !_isFavorite); // Cập nhật màu tim realtime
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.star_purple500_outlined,
                            color: Colors.amber),
                        iconSize: 32,
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Đã ghi nhận vote ${movie.rating}/10 điểm cho phim!')),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.blue),
                        iconSize: 32,
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Đã sao chép liên kết chia sẻ phim thành công!')),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // 4. OVERVIEW TEXT WITH PADDING
                  const Text('Tóm Tắt Cốt Truyện',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: const TextStyle(
                        fontSize: 16, height: 1.5, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),
                  const Divider(height: 30),

                  // 5. TRAILERS LIST SECTION: Khối danh sách trailer cuộn lồng an toàn
                  const Text('Video Giới Thiệu (Trailers)',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Khắc phục triệt để lỗi xung đột cuộn vô hạn bằng physics khóa cuộn lồng nhau
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: movie.trailers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.play_circle_fill,
                              color: Colors.redAccent),
                          title: Text(movie.trailers[index].title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '🚀 Đang mở luồng phát: ${movie.trailers[index].title}')),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
