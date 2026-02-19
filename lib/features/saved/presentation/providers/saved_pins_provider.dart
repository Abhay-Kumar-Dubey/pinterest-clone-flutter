import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/saved_pins_local_datasource.dart';
import '../../domain/entities/saved_pin.dart';

final savedPinsDataSourceProvider = Provider<SavedPinsLocalDataSource>((ref) {
  return SavedPinsLocalDataSource();
});

class SavedPinsState {
  final List<SavedPin> pins;
  final bool isLoading;
  final String? error;

  SavedPinsState({
    this.pins = const [],
    this.isLoading = false,
    this.error,
  });

  SavedPinsState copyWith({
    List<SavedPin>? pins,
    bool? isLoading,
    String? error,
  }) {
    return SavedPinsState(
      pins: pins ?? this.pins,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SavedPinsNotifier extends StateNotifier<SavedPinsState> {
  final SavedPinsLocalDataSource _dataSource;

  SavedPinsNotifier(this._dataSource) : super(SavedPinsState());

  Future<void> loadSavedPins() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final pins = await _dataSource.getAllSavedPins();
      state = state.copyWith(pins: pins, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load saved pins: $e',
        isLoading: false,
      );
    }
  }

  Future<bool> savePin({
    required String imageUrl,
    required String photographer,
    required double aspectRatio,
    required int originalIndex,
  }) async {
    try {
      final pin = SavedPin(
        imageUrl: imageUrl,
        photographer: photographer,
        aspectRatio: aspectRatio,
        originalIndex: originalIndex,
        savedAt: DateTime.now(),
      );
      
      await _dataSource.savePin(pin);
      await loadSavedPins(); // Reload to update UI
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to save pin: $e');
      return false;
    }
  }

  Future<bool> isPinSaved(String imageUrl) async {
    try {
      return await _dataSource.isPinSaved(imageUrl);
    } catch (e) {
      return false;
    }
  }

  Future<void> deletePin(String imageUrl) async {
    try {
      await _dataSource.deletePin(imageUrl);
      await loadSavedPins(); // Reload to update UI
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete pin: $e');
    }
  }

  Future<void> clearAllPins() async {
    try {
      await _dataSource.clearAllPins();
      state = state.copyWith(pins: []);
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear pins: $e');
    }
  }
}

final savedPinsProvider =
    StateNotifierProvider<SavedPinsNotifier, SavedPinsState>((ref) {
  final dataSource = ref.watch(savedPinsDataSourceProvider);
  return SavedPinsNotifier(dataSource);
});
