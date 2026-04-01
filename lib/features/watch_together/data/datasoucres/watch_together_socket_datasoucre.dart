import 'package:pixel_love/core/services/socket_service.dart';

abstract class WatchTogetherSocketDataSource {
  void initPlayer(String? videoId, {bool resetQueue = false});
  void updatePlayer({required String type, required double time});
  void nextVideo();
  void sendEnded();
}

class WatchTogetherSocketDatasoucreImpl
    implements WatchTogetherSocketDataSource {
  final SocketService _socketService;
  WatchTogetherSocketDatasoucreImpl(this._socketService);

  void _emit(String event, [dynamic data]) {
    _socketService.emitToEvents(event, data);
  }

  @override
  void initPlayer(String? videoId, {bool resetQueue = false}) {
    _emit('player:init', {
      'mode': 'video',
      if (videoId != null && videoId.isNotEmpty) 'videoId': videoId,
      'resetQueue': resetQueue,
    });
  }

  @override
  void nextVideo() {
    _emit('player:next');
  }

  @override
  void sendEnded() {
    _emit('player:ended');
  }

  @override
  void updatePlayer({required String type, required double time}) {
      _emit('player:update', {'type': type, 'time': time});

  }
}
