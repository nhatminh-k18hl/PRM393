import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../data/movie_data.dart';

class MovieBrowsingScreen extends StatefulWidget {
  const MovieBrowsingScreen({super.key});

  @override
  State<MovieBrowsingScreen> createState() => _MovieBrowsingScreenState();
}

class _MovieBrowsingScreenState extends State<MovieBrowsingScreen> {
  // Biến quản lý trạng thái tìm kiếm, lọc và sắp xếp
  String _searchQuery = '';
  String _selectedGenre = 'All';
  String _sortBy = 'A-Z';

  // Danh mục tất cả thể loại phim mẫu hiện có
  final List<String> _genres = [
    'All',
    'Action',
    'Sci-Fi',
    'Adventure',
    'Drama',
    'Animation',
    'Fantasy'
  ];

  // Hàm xử lý kết hợp đồng thời cả Tìm kiếm, Lọc Thể loại và Sắp xếp
  List<Movie> _getProcessedMovies() {
    List<Movie> filtered = allMovies.where((movie) {
      final matchSearch =
          movie.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchGenre =
          _selectedGenre == 'All' || movie.genres.contains(_selectedGenre);
      return matchSearch && matchGenre;
    }).toList();

    // Thuật toán sắp xếp dựa theo Dropdown chọn lựa
    if (_sortBy == 'A-Z') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'Z-A') {
      filtered.sort((a, b) => b.title.compareTo(a.title));
    } else if (_sortBy == 'Year') {
      filtered.sort((a, b) => b.year.compareTo(a.year));
    } else if (_sortBy == 'Rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<Movie> displayList = _getProcessedMovies();

    // [TỐI ƯU MOBILE UX]: Bọc GestureDetector tự động ẩn bàn phím ảo khi chạm ra ngoài
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find a Movie',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: Column(
          children: [
            // =========================================================================
            // LAB 6.1 – RESPONSIVE HERO BANNER (ĐÃ THU NHỎ SIÊU GỌN CHỐNG CHIẾM DIỆN TÍCH)
            // =========================================================================
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.blueAccent,
                  Colors.purpleAccent.withOpacity(0.8)
                ]),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Khám Phá Điện Ảnh',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Row(
                    children: [
                      _buildHeroButton('🔥 Hot', Colors.amber),
                      const SizedBox(width: 6),
                      _buildHeroButton('🎟️ Vé', Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            // =========================================================================
            // LAB 6.2 – SEARCH, GENRE CHIPS & SORT BAR (TỐI ƯU KHÔNG GIAN CUỘN NGANG)
            // =========================================================================
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, left: 12.0, right: 12.0, bottom: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ô tìm kiếm Search Box mảnh dẻ gọn gàng
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Nhập từ khóa tìm kiếm phim...',
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.blueAccent, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // [TỐI ƯU SỬA LỖI CHIẾM DIỆN TÍCH]: Chuyển sang cuộn ngang trên 1 dòng độc nhất
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _genres.map((genre) {
                        final bool isSelected = _selectedGenre == genre;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(genre,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 13)),
                            selected: isSelected,
                            selectedColor: Colors.blueAccent,
                            backgroundColor: Colors.grey[200],
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onSelected: (bool selected) {
                              if (selected)
                                setState(() => _selectedGenre = genre);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Thanh công cụ Sort Bar lựa chọn sắp xếp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kết quả: ${displayList.length}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey,
                              fontSize: 13)),
                      Row(
                        children: [
                          const Icon(Icons.sort,
                              size: 16, color: Colors.blueAccent),
                          const SizedBox(width: 4),
                          // [ĐÃ FIX LỖI BIÊN DỊCH]: Thay thế dense bằng thuộc tính chuẩn isDense: true
                          DropdownButton<String>(
                            value: _sortBy,
                            isDense: true,
                            underline: const SizedBox(),
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 13),
                            items: <String>['A-Z', 'Z-A', 'Year', 'Rating']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                  value: value, child: Text('Sắp xếp: $value'));
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null)
                                setState(() => _sortBy = newValue);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

            // =========================================================================
            // LAB 6.3 – RESPONSIVE MOVIE LIST & GRID SYSTEM
            // =========================================================================
            Expanded(
              child: displayList.isEmpty
                  ? const Center(
                      child: Text('Không tìm thấy phim nào khớp với bộ lọc!'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 800) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(12.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.3,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) => _buildMovieCard(
                                displayList[index],
                                isTablet: true),
                          );
                        } else {
                          return ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) => _buildMovieCard(
                                displayList[index],
                                isTablet: false),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Khối dựng nút nhấn nhỏ gọn trong khu vực Hero Banner
  Widget _buildHeroButton(String label, Color bgColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor:
            bgColor == Colors.amber ? Colors.black87 : Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {},
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  // Khối dựng thẻ hiển thị thông tin phim thích ứng (ĐÃ FIX CROSSAXISALIGNMENT TYPO)
  Widget _buildMovieCard(Movie movie, {required bool isTablet}) {
    return Card(
      elevation: 3,
      margin: isTablet ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            child: Image.network(
              movie.posterUrl,
              width: isTablet ? 90 : 85,
              height: isTablet ? 130 : 120,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Container(
                      width: 85,
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2))),
              errorBuilder: (context, error, trace) => Container(
                  width: 85,
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Sửa chính xác CrossAxisAlignment chuẩn cú pháp
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(movie.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Năm phát hành: ${movie.year} | ⭐ ${movie.rating}/10',
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 2.0,
                    children: movie.genres
                        .map((g) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(g,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
