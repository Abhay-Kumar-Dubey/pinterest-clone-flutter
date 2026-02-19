class Photo {
  final int id;
  final String imageUrl;
  final String originalImageUrl;
  final String photographer;
  final String alt;
  final int width;
  final int height;

  Photo({
    required this.id,
    required this.imageUrl,
    required this.originalImageUrl,
    required this.photographer,
    required this.alt,
    required this.width,
    required this.height,
  });

  double get aspectRatio => height / width;
}
