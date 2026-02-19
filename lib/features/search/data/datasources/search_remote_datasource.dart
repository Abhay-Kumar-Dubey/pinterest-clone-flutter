import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/search_photo_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchPhotoModel>> searchPhotos(String query, {int page = 1, int perPage = 20});
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final DioClient dioClient;

  SearchRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<SearchPhotoModel>> searchPhotos(String query, {int page = 1, int perPage = 20}) async {
    try {
      final response = await dioClient.dio.get(
        '/search',
        queryParameters: {
          'query': query,
          'page': page,
          'per_page': perPage,
        },
      );

      final List<dynamic> photosJson = response.data['photos'] ?? [];
      return photosJson.map((json) => SearchPhotoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to search photos: ${e.message}');
    }
  }
}
