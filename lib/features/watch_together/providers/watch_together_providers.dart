import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:pixel_love/features/watch_together/presentation/notifiers/yt_controller_notifier.dart';
import 'package:pixel_love/features/watch_together/data/datasoucres/watch_together_remote_datasource.dart';
import 'package:pixel_love/features/watch_together/data/datasoucres/watch_together_socket_datasoucre.dart';
import 'package:pixel_love/features/watch_together/data/repositories/watch_together_repository_impl.dart';
import 'package:pixel_love/features/watch_together/domain/repositories/watch_together_repository.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/add_video_usecase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/get_video_usercase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/init_player_usecase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/next_video_usecase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/remove_video_usecase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/send_ended_usecase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/update_video_usecase.dart';
import 'package:pixel_love/features/watch_together/presentation/notifiers/watch_together_notifier.dart';

final watchTogetherRemoteDataSoucreProvider =
    Provider<WatchTogetherRemoteDataSource>((ref) {
  return WatchTogetherRemoteDataSourceImpl(ref.read(dioApiProvider));
});

final watchTogetherSokectDataSoucreProvider =
    Provider<WatchTogetherSocketDataSource>((ref) {
  return WatchTogetherSocketDatasoucreImpl(ref.read(socketServiceProvider));
});

final watchTogetherRepositoryProvider =
    Provider<WatchTogetherRepository>((ref) {
  return WatchTogetherRepositoryImpl(
    ref.read(watchTogetherRemoteDataSoucreProvider),
    ref.read(watchTogetherSokectDataSoucreProvider),
  );
});

final getVideoStateUseCaseProvider = Provider<GetVideoUsercase>((ref) {
  return GetVideoUsercase(ref.watch(watchTogetherRepositoryProvider));
});

final addVideoUseCaseProvider = Provider<AddVideoUsecase>((ref) {
  return AddVideoUsecase(ref.watch(watchTogetherRepositoryProvider));
});

final removeVideoUseCaseProvider = Provider<RemoveVideoUsecase>((ref) {
  return RemoveVideoUsecase(ref.watch(watchTogetherRepositoryProvider));
});

final updateVideoUseCaseProvider = Provider<UpdateVideoUsecase>((ref) {
  return UpdateVideoUsecase(ref.watch(watchTogetherRepositoryProvider));
});

final nextVideoUseCaseProvider = Provider<NextVideoUsecase>((ref) {
  return NextVideoUsecase(ref.watch(watchTogetherRepositoryProvider));
});

final sendEndedUseCaseProvider = Provider<SendEndedUsecase>((ref) {
  return SendEndedUsecase(ref.watch(watchTogetherRepositoryProvider));
});

final initPlayerUseCaseProvider = Provider<InitPlayerUsecase>((ref) {
  return InitPlayerUsecase(ref.watch(watchTogetherRepositoryProvider));
});

final watchTogetherNotifierProvider =
    NotifierProvider<WatchTogetherNotifier, WatchTogetherUIState>(
  WatchTogetherNotifier.new,
);

// Controller provider: WtPlayer set khi tạo controller mới, WtControls đọc để lấy currentTime
final ytControllerProvider =
    NotifierProvider<YtControllerNotifier, YoutubePlayerController?>(
  YtControllerNotifier.new,
);