import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/radio/data/datasources/radio_remote_datasource.dart';
import 'package:pixel_love/features/radio/data/repositories/radio_repository_impl.dart';
import 'package:pixel_love/features/radio/domain/repositories/radio_repository.dart';
import 'package:pixel_love/features/radio/domain/usecases/get_voices_usecase.dart';
import 'package:pixel_love/features/radio/presentation/notifiers/radio_notifier.dart';

final radioRemoteDataSourceProvider = Provider<RadioRemoteDataSource>((ref) {
  final dioApi = ref.watch(dioApiProvider);
  return RadioRemoteDataSourceImpl(dioApi);
});

final radioRepositoryProvider = Provider<RadioRepository>((ref) {
  final remoteDataSource = ref.watch(radioRemoteDataSourceProvider);
  return RadioRepositoryImpl(remoteDataSource);
});

final getVoicesUseCaseProvider = Provider<GetVoicesUseCase>((ref) {
  final repository = ref.watch(radioRepositoryProvider);
  return GetVoicesUseCase(repository);
});

final radioNotifierProvider = NotifierProvider<RadioNotifier, RadioState>(
  RadioNotifier.new,
);
