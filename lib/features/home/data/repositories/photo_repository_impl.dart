import '../../../../core/utils/result.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../datasources/photo_remote_datasource.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteDataSource remoteDataSource;

  PhotoRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<Photo>>> getCuratedPhotos({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final photoModels = await remoteDataSource.getCuratedPhotos(
        page: page,
        perPage: perPage,
      );
      final photos = photoModels.map((model) => model.toEntity()).toList();
      return Success(photos);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
