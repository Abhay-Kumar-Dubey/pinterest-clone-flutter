import '../../../../core/utils/result.dart';
import '../entities/photo.dart';

abstract class PhotoRepository {
  Future<Result<List<Photo>>> getCuratedPhotos({int page = 1, int perPage = 20});
}
