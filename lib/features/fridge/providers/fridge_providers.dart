import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/fridge/data/datasources/fridge_remote_datasource.dart';
import 'package:pixel_love/features/fridge/data/repositories/fridge_repository_impl.dart';
import 'package:pixel_love/features/fridge/domain/repositories/fridge_repository.dart';
import 'package:pixel_love/features/fridge/domain/usecases/create_note_usecase.dart';
import 'package:pixel_love/features/fridge/domain/usecases/get_fridge_data_usecase.dart';
import 'package:pixel_love/features/fridge/presentation/notifiers/create_note_notifier.dart';
import 'package:pixel_love/features/fridge/presentation/notifiers/fridge_notifier.dart';

// ============================================
// Fridge Feature Providers
// ============================================

/// Fridge Remote DataSource provider
final fridgeRemoteDataSourceProvider = Provider<FridgeRemoteDataSource>((ref) {
  final dioApi = ref.watch(dioApiProvider);
  return FridgeRemoteDataSourceImpl(dioApi);
});

/// Fridge Repository provider
final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  final remoteDataSource = ref.watch(fridgeRemoteDataSourceProvider);
  return FridgeRepositoryImpl(remoteDataSource);
});

/// Get Fridge Data UseCase provider
final getFridgeDataUseCaseProvider = Provider<GetFridgeDataUseCase>((ref) {
  final repository = ref.watch(fridgeRepositoryProvider);
  return GetFridgeDataUseCase(repository);
});

/// Fridge Notifier provider (Riverpod v3)
final fridgeNotifierProvider = NotifierProvider<FridgeNotifier, FridgeState>(
  FridgeNotifier.new,
);

/// Create Note UseCase provider
final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  final repository = ref.watch(fridgeRepositoryProvider);
  return CreateNoteUseCase(repository);
});

/// Create Note Notifier provider (Riverpod v3)
final createNoteNotifierProvider =
    NotifierProvider<CreateNoteNotifier, CreateNoteState>(
  CreateNoteNotifier.new,
);

