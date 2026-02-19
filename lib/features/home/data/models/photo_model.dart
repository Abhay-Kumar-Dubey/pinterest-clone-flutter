import 'package:pinterest_clone_assignment/features/home/domain/entities/photo.dart';

class PhotoModel {
  final int id;
  final int width;
  final int height;
  final String url;
  final String photographer;
  final String photographerUrl;
  final int photographerId;
  final String avgColor;
  final PhotoSourceModel src;
  final bool liked;
  final String alt;

  PhotoModel({
    required this.id,
    required this.width,
    required this.height,
    required this.url,
    required this.photographer,
    required this.photographerUrl,
    required this.photographerId,
    required this.avgColor,
    required this.src,
    required this.liked,
    required this.alt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] ?? 0,
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      url: json['url'] ?? '',
      photographer: json['photographer'] ?? '',
      photographerUrl: json['photographer_url'] ?? '',
      photographerId: json['photographer_id'] ?? 0,
      avgColor: json['avg_color'] ?? '',
      src: PhotoSourceModel.fromJson(json['src'] ?? {}),
      liked: json['liked'] ?? false,
      alt: json['alt'] ?? '',
    );
  }

  Photo toEntity() {
    return Photo(
      id: id,
      imageUrl: src.medium,
      originalImageUrl: src.original,
      photographer: photographer,
      alt: alt,
      width: width,
      height: height,
    );
  }
}

class PhotoSourceModel {
  final String original;
  final String large2x;
  final String large;
  final String medium;
  final String small;
  final String portrait;
  final String landscape;
  final String tiny;

  PhotoSourceModel({
    required this.original,
    required this.large2x,
    required this.large,
    required this.medium,
    required this.small,
    required this.portrait,
    required this.landscape,
    required this.tiny,
  });

  factory PhotoSourceModel.fromJson(Map<String, dynamic> json) {
    return PhotoSourceModel(
      original: json['original'] ?? '',
      large2x: json['large2x'] ?? '',
      large: json['large'] ?? '',
      medium: json['medium'] ?? '',
      small: json['small'] ?? '',
      portrait: json['portrait'] ?? '',
      landscape: json['landscape'] ?? '',
      tiny: json['tiny'] ?? '',
    );
  }
}
