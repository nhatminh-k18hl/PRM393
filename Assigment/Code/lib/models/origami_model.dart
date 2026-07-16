class OrigamiModel {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final List<String> categories;
  final String previewImg;
  final String downloadUrl;
  final Map<String, dynamic> materials;

  const OrigamiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.categories,
    required this.previewImg,
    required this.downloadUrl,
    required this.materials,
  });

  factory OrigamiModel.fromJson(Map<String, dynamic> json) {
    return OrigamiModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      categories: List<String>.from(json['categories'] as List),
      previewImg: json['preview_img'] as String,
      downloadUrl: json['download_url'] as String,
      materials: Map<String, dynamic>.from(json['materials'] as Map),
    );
  }
}
