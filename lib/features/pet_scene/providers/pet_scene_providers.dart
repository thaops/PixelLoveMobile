import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/pet_scene/data/datasources/pet_scene_remote_datasource.dart';
import 'package:pixel_love/features/pet_scene/data/repositories/pet_scene_repository_impl.dart';
import 'package:pixel_love/features/pet_scene/domain/repositories/pet_scene_repository.dart';
import 'package:pixel_love/features/pet_scene/domain/usecases/get_pet_scene_usecase.dart';
import 'package:pixel_love/features/pet_scene/presentation/notifiers/pet_scene_notifier.dart';

// ============================================
// Pet Scene Feature Providers
// ============================================

/// Pet Scene Remote DataSource provider
final petSceneRemoteDataSourceProvider = Provider<PetSceneRemoteDataSource>((ref) {
  final dioApi = ref.watch(dioApiProvider);
  return PetSceneRemoteDataSourceImpl(dioApi);
});

/// Pet Scene Repository provider
final petSceneRepositoryProvider = Provider<PetSceneRepository>((ref) {
  final remoteDataSource = ref.watch(petSceneRemoteDataSourceProvider);
  return PetSceneRepositoryImpl(remoteDataSource);
});

/// Get Pet Scene UseCase provider
final getPetSceneUseCaseProvider = Provider<GetPetSceneUseCase>((ref) {
  final repository = ref.watch(petSceneRepositoryProvider);
  return GetPetSceneUseCase(repository);
});

/// Pet Scene Notifier provider (Riverpod v3)
final petSceneNotifierProvider = NotifierProvider<PetSceneNotifier, PetSceneState>(
  PetSceneNotifier.new,
);

