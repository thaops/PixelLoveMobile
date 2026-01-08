import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';
import 'package:pixel_love/features/fridge/providers/fridge_providers.dart';

/// Fridge State
class FridgeState {
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final Fridge? fridgeData;

  const FridgeState({
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.fridgeData,
  });

  FridgeState copyWith({
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    Fridge? fridgeData,
  }) {
    return FridgeState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage ?? this.errorMessage,
      fridgeData: fridgeData ?? this.fridgeData,
    );
  }
}

/// Fridge Notifier
class FridgeNotifier extends Notifier<FridgeState> {
  @override
  FridgeState build() {
    // Load data khi khởi tạo
    Future.microtask(() {
      _loadFridgeData();
    });
    return const FridgeState();
  }

  Future<void> _loadFridgeData() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final getFridgeDataUseCase = ref.read(getFridgeDataUseCaseProvider);
      final result = await getFridgeDataUseCase.call();

      result.when(
        success: (fridge) {
          state = state.copyWith(
            fridgeData: fridge,
            isLoading: false,
          );
        },
        error: (error) {
          state = state.copyWith(
            errorMessage: error.message,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Unexpected error: $e',
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    await _loadFridgeData();
  }
}

