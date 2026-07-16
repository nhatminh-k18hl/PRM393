// Định nghĩa cấu trúc dữ liệu Trailer phim
class Trailer {
  final String title;

  Trailer({required this.title});
}

// Định nghĩa cấu trúc dữ liệu bộ phim (Movie model class)
class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl; // Ảnh nền lớn làm banner trên cùng
  final String overview;
  final List<String> genres;
  final double rating;
  final List<Trailer> trailers;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.overview,
    required this.genres,
    required this.rating,
    required this.trailers,
  });
}
