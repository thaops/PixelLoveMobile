import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/tarot/data/datasources/tarot_remote_datasource.dart';
import 'package:pixel_love/features/tarot/data/repositories/tarot_repository_impl.dart';
import 'package:pixel_love/features/tarot/domain/repositories/tarot_repository.dart';
import 'package:pixel_love/features/tarot/notifiers/tarot_notifier.dart';
import 'package:pixel_love/features/tarot/notifiers/tarot_state.dart';

final tarotRemoteDataSourceProvider = Provider<TarotRemoteDataSource>((ref) {
  final dioApi = ref.watch(dioApiProvider);
  return TarotRemoteDataSourceImpl(dioApi);
});

final tarotRepositoryProvider = Provider<TarotRepository>((ref) {
  final remoteDataSource = ref.watch(tarotRemoteDataSourceProvider);
  return TarotRepositoryImpl(remoteDataSource);
});

final tarotNotifierProvider = NotifierProvider<TarotNotifier, TarotState>(
  TarotNotifier.new,
);
