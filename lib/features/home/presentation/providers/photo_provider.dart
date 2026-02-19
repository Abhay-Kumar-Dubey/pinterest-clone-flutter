import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/photo_remote_datasource.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../domain/entities/photo.dart';
import '../../domain/usecases/get_curated_photos.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final photoRemoteDataSourceProvider = Provider<PhotoRemoteDataSource>(
  (ref) => PhotoRemoteDataSourceImpl(ref.read(dioClientProvider)),
);

final photoRepositoryProvider = Provider<PhotoRepositoryImpl>(
  (ref) => PhotoRepositoryImpl(ref.read(photoRemoteDataSourceProvider)),
);

final getCuratedPhotosUseCaseProvider = Provider<GetCuratedPhotos>(
  (ref) => GetCuratedPhotos(ref.read(photoRepositoryProvider)),
);

class PhotoState {
  final List<Photo> photos;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  PhotoState({
    this.photos = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  PhotoState copyWith({
    List<Photo>? photos,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return PhotoState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class PhotoNotifier extends StateNotifier<PhotoState> {
  final GetCuratedPhotos getCuratedPhotos;

  PhotoNotifier(this.getCuratedPhotos) : super(PhotoState());

  Future<void> loadPhotos({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = PhotoState(isLoading: true);
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(isLoading: true, error: null);
    }

    final page = refresh ? 1 : state.currentPage;
    final result = await getCuratedPhotos(page: page, perPage: 20);

    switch (result) {
      case Success<List<Photo>>():
        final newPhotos = result.data;
        state = state.copyWith(
          photos: refresh ? newPhotos : [...state.photos, ...newPhotos],
          isLoading: false,
          currentPage: page + 1,
          hasMore: newPhotos.isNotEmpty,
          error: null,
        );
      case Failure<List<Photo>>():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }
}

final photoProvider = StateNotifierProvider<PhotoNotifier, PhotoState>(
  (ref) => PhotoNotifier(ref.read(getCuratedPhotosUseCaseProvider)),
);
