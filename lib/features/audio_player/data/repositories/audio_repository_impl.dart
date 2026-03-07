import 'package:pixel_love/core/network/api_result.dart';
import '../datasources/audio_remote_datasource.dart';
import '../../domain/entities/audio_player_state.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDataSource _remoteDataSource;

  AudioRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<AudioPlayerState>> getPlayerState() async {
    final result = await _remoteDataSource.getPlayerState();
    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (failure) => ApiResult.error(failure),
    );
  }

  @override
  Future<ApiResult<Track>> addTrack({
    required String youtubeUrl,
    String? title,
    String? thumbnail,
    String? audioUrl,
    num? duration,
  }) async {
    final result = await _remoteDataSource.addTrack(
      youtubeUrl: youtubeUrl,
      title: title,
      thumbnail: thumbnail,
      audioUrl: audioUrl,
      duration: duration,
    );
    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (failure) => ApiResult.error(failure),
    );
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> checkTrack(String youtubeUrl) async {
    return _remoteDataSource.checkTrack(youtubeUrl);
  }

  @override
  Future<ApiResult<void>> removeTrack(String trackId) async {
    return _remoteDataSource.removeTrack(trackId);
  }

  @override
  Future<ApiResult<List<Track>>> getQueue() async {
    final result = await _remoteDataSource.getQueue();
    return result.when(
      success: (list) =>
          ApiResult.success(list.map((e) => e.toEntity()).toList()),
      error: (failure) => ApiResult.error(failure),
    );
  }

  @override
  Future<ApiResult<void>> playTrack(String trackId, {num? startTime}) async {
    return _remoteDataSource.playTrack(trackId, startTime: startTime);
  }

  @override
  Future<ApiResult<void>> pauseTrack() async {
    return _remoteDataSource.pauseTrack();
  }

  @override
  Future<ApiResult<void>> seekTrack(num time) async {
    return _remoteDataSource.seekTrack(time);
  }

  @override
  Future<ApiResult<String>> nextTrack() async {
    return _remoteDataSource.nextTrack();
  }

  @override
  Future<ApiResult<String>> previousTrack() async {
    return _remoteDataSource.previousTrack();
  }

  @override
  Future<ApiResult<void>> setTimer(int minutes) async {
    return _remoteDataSource.setTimer(minutes);
  }
}
