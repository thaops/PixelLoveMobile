import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/watch_together/data/datasoucres/watch_together_remote_datasource.dart';
import 'package:pixel_love/features/watch_together/data/datasoucres/watch_together_socket_datasoucre.dart';
import 'package:pixel_love/features/watch_together/domain/entities/video_player_state.dart';
import 'package:pixel_love/features/watch_together/domain/repositories/watch_together_repository.dart';

class WatchTogetherRepositoryImpl implements WatchTogetherRepository {
  final WatchTogetherRemoteDataSource _remote;
  final WatchTogetherSocketDataSource _socket;
  WatchTogetherRepositoryImpl(this._remote, this._socket);
  @override
  Future<ApiResult<bool>> addVideo(String url) {
   return _remote.addVideo(url);
  }

  @override
  void initPlayer(String? videoId, {bool resetQueue = false}) {
    _socket.initPlayer(videoId, resetQueue: resetQueue);
  }

  
  @override
  Future<ApiResult<VideoPlayerState>> getVideoState() async {
    final result = await _remote.getVideoState();
    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (e) => ApiResult.error(e),
    );
  }

  @override
  void nextVideo() {
    _socket.nextVideo();
  }

  @override
  Future<ApiResult<bool>> removeVideo(String itemId) {
    return _remote.removeVideo(itemId);
  }

  @override
  void sendEnded() {
    _socket.sendEnded();
  }

  @override
  void updatePlayer({required String type, required double time}) {
    _socket.updatePlayer(type: type, time: time);
  }
}