class SavedPin {
  final int? id;
  final String imageUrl;
  final String photographer;
  final double aspectRatio;
  final int originalIndex;
  final DateTime savedAt;

  SavedPin({
    this.id,
    required this.imageUrl,
    required this.photographer,
    required this.aspectRatio,
    required this.originalIndex,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'photographer': photographer,
      'aspectRatio': aspectRatio,
      'originalIndex': originalIndex,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedPin.fromMap(Map<String, dynamic> map) {
    return SavedPin(
      id: map['id'] as int?,
      imageUrl: map['imageUrl'] as String,
      photographer: map['photographer'] as String,
      aspectRatio: map['aspectRatio'] as double,
      originalIndex: map['originalIndex'] as int,
      savedAt: DateTime.parse(map['savedAt'] as String),
    );
  }
}
