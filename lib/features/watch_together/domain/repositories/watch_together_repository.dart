
import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/watch_together/domain/entities/video_player_state.dart';

abstract class WatchTogetherRepository {
  // REST
  Future<ApiResult<VideoPlayerState>> getVideoState();
  Future<ApiResult<bool>> addVideo(String url);
  Future<ApiResult<bool>> removeVideo(String itemId);
  // Socket
  void initPlayer(String? videoId, {bool resetQueue = false});
  void updatePlayer({required String type, required double time});
  void nextVideo();
  void sendEnded();
}