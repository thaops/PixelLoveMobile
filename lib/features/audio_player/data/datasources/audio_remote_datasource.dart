import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import '../models/audio_player_state_dto.dart';
import '../models/track_dto.dart';

class AudioRemoteDataSource {
  final DioApi _dioApi;

  AudioRemoteDataSource(this._dioApi);

  Future<ApiResult<AudioPlayerStateDto>> getPlayerState() async {
    return _dioApi.get(
      '/player/state',
      fromJson: (data) => AudioPlayerStateDto.fromJson(data),
    );
  }

  Future<ApiResult<TrackDto>> addTrack(String youtubeUrl) async {
    return _dioApi.post(
      '/rooms/tracks',
      data: {'youtubeUrl': youtubeUrl},
      fromJson: (data) => TrackDto.fromJson(data),
    );
  }

  Future<ApiResult<void>> removeTrack(String trackId) async {
    return _dioApi.delete('/rooms/tracks/$trackId', fromJson: (_) => null);
  }

  Future<ApiResult<List<TrackDto>>> getQueue() async {
    return _dioApi.get(
      '/player/queue',
      fromJson: (data) {
        final list = data as List;
        return list.map((e) => TrackDto.fromJson(e)).toList();
      },
    );
  }

  Future<ApiResult<void>> playTrack(String trackId, {num? startTime}) async {
    return _dioApi.post(
      '/player/play',
      data: {'trackId': trackId, if (startTime != null) 'startTime': startTime},
      fromJson: (_) => null,
    );
  }

  Future<ApiResult<void>> pauseTrack() async {
    return _dioApi.post('/player/pause', fromJson: (_) => null);
  }

  Future<ApiResult<void>> seekTrack(num time) async {
    return _dioApi.post(
      '/player/seek',
      data: {'time': time},
      fromJson: (_) => null,
    );
  }

  Future<ApiResult<String>> nextTrack() async {
    return _dioApi.post(
      '/player/next',
      fromJson: (data) => (data as Map<String, dynamic>)['trackId'] ?? '',
    );
  }

  Future<ApiResult<String>> previousTrack() async {
    return _dioApi.post(
      '/player/previous',
      fromJson: (data) => (data as Map<String, dynamic>)['trackId'] ?? '',
    );
  }

  Future<ApiResult<void>> setTimer(int minutes) async {
    return _dioApi.post(
      '/player/timer',
      data: {'minutes': minutes},
      fromJson: (_) => null,
    );
  }
}
