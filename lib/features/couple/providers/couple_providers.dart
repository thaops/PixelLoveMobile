import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/couple/data/datasources/couple_remote_datasource.dart';
import 'package:pixel_love/features/couple/data/repositories/couple_repository_impl.dart';
import 'package:pixel_love/features/couple/domain/repositories/couple_repository.dart';
import 'package:pixel_love/features/couple/domain/usecases/create_code_usecase.dart';
import 'package:pixel_love/features/couple/domain/usecases/pair_couple_usecase.dart';
import 'package:pixel_love/features/couple/domain/usecases/preview_code_usecase.dart';
import 'package:pixel_love/features/couple/presentation/notifiers/couple_connection_notifier.dart';

// ============================================
// Couple Feature Providers
// ============================================

/// Couple Remote DataSource provider
final coupleRemoteDataSourceProvider = Provider<CoupleRemoteDataSource>((ref) {
  final dioApi = ref.watch(dioApiProvider);
  return CoupleRemoteDataSourceImpl(dioApi);
});

/// Couple Repository provider
final coupleRepositoryProvider = Provider<CoupleRepository>((ref) {
  final remoteDataSource = ref.watch(coupleRemoteDataSourceProvider);
  return CoupleRepositoryImpl(remoteDataSource);
});

/// Create Code UseCase provider
final createCodeUseCaseProvider = Provider<CreateCodeUseCase>((ref) {
  final repository = ref.watch(coupleRepositoryProvider);
  return CreateCodeUseCase(repository);
});

/// Preview Code UseCase provider
final previewCodeUseCaseProvider = Provider<PreviewCodeUseCase>((ref) {
  final repository = ref.watch(coupleRepositoryProvider);
  return PreviewCodeUseCase(repository);
});

/// Pair Couple UseCase provider
final pairCoupleUseCaseProvider = Provider<PairCoupleUseCase>((ref) {
  final repository = ref.watch(coupleRepositoryProvider);
  return PairCoupleUseCase(repository);
});

/// Couple Connection Notifier provider (Riverpod v3)
final coupleConnectionNotifierProvider = NotifierProvider<CoupleConnectionNotifier, CoupleConnectionState>(
  CoupleConnectionNotifier.new,
);

