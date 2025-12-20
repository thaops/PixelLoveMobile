import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/home/data/datasources/home_remote_datasource.dart';
import 'package:pixel_love/features/home/data/repositories/home_repository_impl.dart';
import 'package:pixel_love/features/home/domain/repositories/home_repository.dart';
import 'package:pixel_love/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:pixel_love/features/home/presentation/notifiers/home_notifier.dart';

// ============================================
// Home Feature Providers
// ============================================

/// Home Remote DataSource provider
final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final dioApi = ref.watch(dioApiProvider);
  return HomeRemoteDataSourceImpl(dioApi);
});

/// Home Repository provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource);
});

/// Get Home Data UseCase provider
final getHomeDataUseCaseProvider = Provider<GetHomeDataUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetHomeDataUseCase(repository);
});

/// Home Notifier provider (Riverpod v3)
final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

