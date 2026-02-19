import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageDownloadService {
  final Dio _dio = Dio();

  Future<bool> downloadImage(String imageUrl) async {
    try {
      debugPrint('Starting image download: $imageUrl');

      final tempDir = await getTemporaryDirectory();
      final fileName = 'pinterest_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      debugPrint('Downloading to temp file: $filePath');

      await _dio.download(imageUrl, filePath);

      debugPrint('Image downloaded, saving to gallery...');

      await Gal.putImage(filePath, album: 'Pinterest');

      debugPrint('Image saved to gallery successfully!');

      try {
        await File(filePath).delete();
        debugPrint('Temp file deleted');
      } catch (e) {
        debugPrint('Failed to delete temp file: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error downloading image: $e');

      if (e is GalException) {
        if (e.type == GalExceptionType.accessDenied) {
          throw Exception(
            'Storage permission denied. Please grant permission in settings.',
          );
        }
      }

      rethrow;
    }
  }
}
