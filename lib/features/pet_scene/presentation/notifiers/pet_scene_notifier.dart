import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/pet_scene/domain/entities/pet_scene.dart';
import 'package:pixel_love/features/pet_scene/providers/pet_scene_providers.dart';

/// Pet Scene State
class PetSceneState {
  final bool isLoading;
  final String? errorMessage;
  final PetScene? petSceneData;

  const PetSceneState({
    this.isLoading = true,
    this.errorMessage,
    this.petSceneData,
  });

  PetSceneState copyWith({
    bool? isLoading,
    String? errorMessage,
    PetScene? petSceneData,
  }) {
    return PetSceneState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      petSceneData: petSceneData ?? this.petSceneData,
    );
  }
}

/// Pet Scene Notifier - Handles pet scene data loading
class PetSceneNotifier extends Notifier<PetSceneState> {
  @override
  PetSceneState build() {
    // Load pet scene after build completes
    // Use Future.microtask to avoid reading state before initialization
    Future.microtask(() {
      fetchPetScene();
    });
    return const PetSceneState();
  }

  Future<void> fetchPetScene() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final getPetSceneUseCase = ref.read(getPetSceneUseCaseProvider);
      final result = await getPetSceneUseCase.call();

      result.when(
        success: (petScene) {
          state = state.copyWith(petSceneData: petScene, isLoading: false);
          print('✅ Pet scene loaded: ${petScene.objects.length} objects');
        },
        error: (error) {
          state = state.copyWith(errorMessage: error.message, isLoading: false);
          print('❌ Pet scene error: ${error.message}');
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Unexpected error: $e',
        isLoading: false,
      );
      print('❌ Pet scene exception: $e');
    }
  }
}
