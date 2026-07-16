import 'package:flutter/material.dart';

void main() {
  runApp(const LayoutBasicsApp());
}

class LayoutBasicsApp extends StatelessWidget {
  const LayoutBasicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả lập danh sách tiêu đề phim phục vụ ListView.builder
    final List<String> movieTitles = [
      'Avatar: The Way of Water',
      'Oppenheimer',
      'Interstellar',
      'Inception',
      'The Dark Knight',
      'Spider-Man: No Way Home'
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Exercise 3: Movie Home Layout'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner quảng cáo đầu trang ứng dụng bằng cấu trúc Row + Padding
            Padding(
              padding: const EdgeInsets.all(16.0), // Khoảng cách nhất quán 16px
              child: Container(
                padding: const EdgeInsets.all(12.0), // Khoảng cách nhất quán 12px
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8), // Khoảng cách nhất quán 8px
                ),
                child: Row(
                  children: const [
                    Icon(Icons.local_fire_department, color: Colors.orange),
                    SizedBox(width: 8), // Khoảng cách nhất quán 8px
                    Text(
                      'Xu hướng nổi bật trong tuần này!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // Tiêu đề phân đoạn danh mục
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Danh Sách Phim Chiếu Rạp',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12), // Khoảng cách phân tách 12px

            // Thao tác hiển thị cuộn danh sách động tối ưu hiệu năng bộ nhớ bằng ListView.builder
            Expanded(
              child: ListView.builder(
                itemCount: movieTitles.length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0), // Khoảng cách phân tách đều các dòng 12px
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.movie, color: Colors.white),
                        ),
                        title: Text(
                          movieTitles[index],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Thể loại: Hành động / Viễn tưởng #$index'),
                        trailing: const Icon(Icons.play_arrow, color: Colors.deepPurple),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}