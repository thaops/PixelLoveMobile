import 'package:pixel_love/core/network/api_result.dart';
import '../entities/audio_player_state.dart';
import '../entities/track.dart';

abstract class AudioRepository {
  Future<ApiResult<AudioPlayerState>> getPlayerState();
  Future<ApiResult<Track>> addTrack(String youtubeUrl);
  Future<ApiResult<void>> removeTrack(String trackId);
  Future<ApiResult<List<Track>>> getQueue();
  Future<ApiResult<void>> playTrack(String trackId, {num? startTime});
  Future<ApiResult<void>> pauseTrack();
  Future<ApiResult<void>> seekTrack(num time);
  Future<ApiResult<String>> nextTrack();
  Future<ApiResult<String>> previousTrack();
  Future<ApiResult<void>> setTimer(int minutes);
}
