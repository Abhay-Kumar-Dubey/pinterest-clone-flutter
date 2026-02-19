import '../../../../core/utils/result.dart';
import '../entities/photo.dart';
import '../repositories/photo_repository.dart';

class GetCuratedPhotos {
  final PhotoRepository repository;

  GetCuratedPhotos(this.repository);

  Future<Result<List<Photo>>> call({int page = 1, int perPage = 20}) {
    return repository.getCuratedPhotos(page: page, perPage: perPage);
  }
}
