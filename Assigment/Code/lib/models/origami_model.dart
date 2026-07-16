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

  String get assetPath {
    switch (previewImg) {
      case 'folding_paper_3x3_thumb':
        return 'assets/Beginner Origami/Dividing Paper/Folding Paper into Thirds 3 x 3 Grid.png';
      case 'rabbit_ear_fold_thumb':
        return 'assets/Beginner Origami/Folding Techniques/Rabbit Ear Fold/rabbit_ear_fold.png';
      case 'origami_shield_with_cross_thumb':
        return 'assets/Easy Origami/Origami Shield With Cross/Origami Shield With Cross.png';
      default:
        return 'assets/images/$previewImg.png';
    }
  }

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
