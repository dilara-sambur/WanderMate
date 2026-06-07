class TravelCategoryModel {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String imageUrl;
  final String semanticLabel;
  final String geminiPrompt;
  final String mapsQuery;

  const TravelCategoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.imageUrl,
    required this.semanticLabel,
    required this.geminiPrompt,
    required this.mapsQuery,
  });

  factory TravelCategoryModel.fromMap(Map<String, dynamic> map) {
    return TravelCategoryModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      emoji: map['emoji'] as String,
      imageUrl: map['imageUrl'] as String,
      semanticLabel: map['semanticLabel'] as String,
      geminiPrompt: map['geminiPrompt'] as String,
      mapsQuery: map['mapsQuery'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'emoji': emoji,
    'imageUrl': imageUrl,
    'semanticLabel': semanticLabel,
    'geminiPrompt': geminiPrompt,
    'mapsQuery': mapsQuery,
  };
}
