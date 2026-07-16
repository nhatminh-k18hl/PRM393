import '../models/movie.dart';

final List<Movie> sampleMovies = [
  Movie(
    id: 1,
    title: 'Avatar: The Way of Water',
    posterUrl:
        'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=500',
    backdropUrl:
        'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200',
    overview:
        'Đặt bối cảnh hơn một thập kỷ sau các sự kiện của phần phim đầu tiên, bộ phim kể câu chuyện về gia đình Sully, những rắc rối theo sau họ, những nỗ lực họ bỏ ra để giữ an toàn cho nhau, và những bi kịch họ phải chịu đựng để sống sót.',
    genres: ['Hành động', 'Viễn tưởng', 'Phiêu lưu'],
    rating: 7.8,
    trailers: [
      Trailer(title: 'Official Teaser Trailer'),
      Trailer(title: 'Official Main Trailer'),
    ],
  ),
  Movie(
    id: 2,
    title: 'Oppenheimer',
    posterUrl:
        'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=500',
    backdropUrl:
        'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1200',
    overview:
        'Câu chuyện về nhà vật lý lý thuyết người Mỹ J. Robert Oppenheimer, người lãnh đạo Phòng thiện nguyện Los Alamos trong Thế chiến thứ hai, và vai trò của ông trong Dự án Manhattan nhằm phát triển bom nguyên tử.',
    genres: ['Tiểu sử', 'Chính kịch', 'Lịch sử'],
    rating: 8.5,
    trailers: [
      Trailer(title: 'Official Main Trailer 2'),
    ],
  ),
  Movie(
    id: 3,
    title: 'Interstellar',
    posterUrl:
        'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=500',
    backdropUrl:
        'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=1200',
    overview:
        'Trong tương lai khi Trái Đất dần không còn sự sống, một nhóm các nhà thám hiểm không gian phải sử dụng một hố đen mới được khám phá để vượt qua các giới hạn của con người nhằm tìm kiếm một hành tinh mới cho nhân loại.',
    genres: ['Khoa học', 'Viễn tưởng', 'Bí ẩn'],
    rating: 8.7,
    trailers: [
      Trailer(title: 'Official IMAX Technical Trailer'),
    ],
  ),
];
