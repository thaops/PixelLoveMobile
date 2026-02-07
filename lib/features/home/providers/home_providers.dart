import 'package:flutter/material.dart';
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

import 'package:pixel_love/features/home/data/datasources/fake_home_remote_datasource.dart';

// ... other imports

/// Home Remote DataSource provider
final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  // Uncomment to use fake data
   return FakeHomeRemoteDataSource();

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

/// Home Transformation State Provider - Lưu vị trí scroll/pan của home screen
final homeTransformationProvider =
    NotifierProvider<HomeTransformationNotifier, Matrix4?>(
      HomeTransformationNotifier.new,
    );

/// Home Transformation Notifier
class HomeTransformationNotifier extends Notifier<Matrix4?> {
  @override
  Matrix4? build() => null;

  void updateTransformation(Matrix4? matrix) {
    state = matrix;
  }

  void reset() {
    state = null;
  }
}
