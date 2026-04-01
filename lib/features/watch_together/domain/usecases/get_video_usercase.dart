import 'package:pixel_love/features/watch_together/domain/repositories/watch_together_repository.dart';

import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/watch_together/domain/entities/video_player_state.dart';
import 'package:pixel_love/features/watch_together/domain/repositories/watch_together_repository.dart';

class GetVideoUsercase {
  final WatchTogetherRepository _repository;

  GetVideoUsercase(this._repository);

  Future<ApiResult<VideoPlayerState>> call() {
    return _repository.getVideoState();
  }
}