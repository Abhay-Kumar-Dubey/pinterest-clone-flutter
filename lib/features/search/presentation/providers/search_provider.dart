import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/search_photo.dart';

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>(
  (ref) => SearchRemoteDataSourceImpl(ref.read(dioClientProvider)),
);

final searchRepositoryProvider = Provider<SearchRepositoryImpl>(
  (ref) => SearchRepositoryImpl(ref.read(searchRemoteDataSourceProvider)),
);

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

class SearchState {
  final List<SearchPhoto> photos;
  final bool isLoading;
  final String? error;
  final String query;

  SearchState({
    this.photos = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  SearchState copyWith({
    List<SearchPhoto>? photos,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return SearchState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchRepositoryImpl repository;

  SearchNotifier(this.repository) : super(SearchState());

  Future<void> searchPhotos(String query) async {
    if (query.trim().isEmpty) {
      state = SearchState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null, query: query);

    final result = await repository.searchPhotos(query, perPage: 30);

    switch (result) {
      case Success<List<SearchPhoto>>():
        state = state.copyWith(
          photos: result.data,
          isLoading: false,
          error: null,
        );
      case Failure<List<SearchPhoto>>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
    }
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(ref.read(searchRepositoryProvider)),
);

// Category search provider for featured categories
class CategorySearchState {
  final Map<String, List<SearchPhoto>> categoryPhotos;
  final bool isLoading;
  final String? error;

  CategorySearchState({
    this.categoryPhotos = const {},
    this.isLoading = false,
    this.error,
  });

  CategorySearchState copyWith({
    Map<String, List<SearchPhoto>>? categoryPhotos,
    bool? isLoading,
    String? error,
  }) {
    return CategorySearchState(
      categoryPhotos: categoryPhotos ?? this.categoryPhotos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CategorySearchNotifier extends StateNotifier<CategorySearchState> {
  final SearchRepositoryImpl repository;

  CategorySearchNotifier(this.repository) : super(CategorySearchState());

  Future<void> loadCategories() async {
    if (state.categoryPhotos.isNotEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    final categories = ['wallpapers', 'anime', 'landscape', 'Marvel'];
    final Map<String, List<SearchPhoto>> results = {};

    try {
      for (final category in categories) {
        final result = await repository.searchPhotos(category, perPage: 10);
        if (result is Success<List<SearchPhoto>>) {
          results[category] = result.data;
        }
      }

      state = state.copyWith(
        categoryPhotos: results,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final categorySearchProvider = StateNotifierProvider<CategorySearchNotifier, CategorySearchState>(
  (ref) => CategorySearchNotifier(ref.read(searchRepositoryProvider)),
);
