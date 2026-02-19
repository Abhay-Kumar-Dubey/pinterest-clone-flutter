import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/photo_model.dart';

abstract class PhotoRemoteDataSource {
  Future<List<PhotoModel>> getCuratedPhotos({int page = 1, int perPage = 20});
}

class PhotoRemoteDataSourceImpl implements PhotoRemoteDataSource {
  final DioClient dioClient;

  PhotoRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<PhotoModel>> getCuratedPhotos({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.curatedPhotos,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> photos = response.data['photos'] ?? [];
        return photos.map((json) => PhotoModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch photos',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
