import '../../../../core/utils/result.dart';
import '../../domain/entities/search_photo.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  Future<Result<List<SearchPhoto>>> searchPhotos(String query, {int page = 1, int perPage = 20}) async {
    try {
      final photoModels = await remoteDataSource.searchPhotos(query, page: page, perPage: perPage);
      final photos = photoModels.map((model) => model.toEntity()).toList();
      return Success(photos);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
