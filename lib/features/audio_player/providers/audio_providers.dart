import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import '../data/datasources/audio_remote_datasource.dart';
import '../data/repositories/audio_repository_impl.dart';
import '../domain/repositories/audio_repository.dart';
import '../presentation/notifiers/audio_player_notifier.dart';
import '../domain/entities/audio_player_state.dart';
import '../presentation/notifiers/audio_handler.dart';

// Provider for the MyAudioHandler instance.
// It's overridden in main.dart with the initialized instance.
final audioHandlerProvider = Provider<MyAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden');
});

final audioRemoteDataSourceProvider = Provider<AudioRemoteDataSource>((ref) {
  return AudioRemoteDataSource(ref.watch(dioApiProvider));
});

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  return AudioRepositoryImpl(ref.watch(audioRemoteDataSourceProvider));
});

final audioPlayerNotifierProvider =
    NotifierProvider<AudioPlayerNotifier, AudioPlayerState>(
      AudioPlayerNotifier.new,
    );
