class SearchPhoto {
  final int id;
  final String imageUrl;
  final String photographer;
  final String alt;
  final int width;
  final int height;

  SearchPhoto({
    required this.id,
    required this.imageUrl,
    required this.photographer,
    required this.alt,
    required this.width,
    required this.height,
  });

  double get aspectRatio {
    if (width == 0) return 1.5;
    return height / width;
  }
}
