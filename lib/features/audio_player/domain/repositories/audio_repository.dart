import 'package:pixel_love/core/network/api_result.dart';
import '../entities/audio_player_state.dart';
import '../entities/track.dart';
import '../entities/music_library_response.dart';
import '../entities/paginated_queue_response.dart';

abstract class AudioRepository {
  Future<ApiResult<AudioPlayerState>> getPlayerState();
  Future<ApiResult<Track>> addTrack({required String youtubeUrl});
  Future<ApiResult<void>> removeTrack(String trackId);
  Future<ApiResult<PaginatedQueueResponse>> getQueue({
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<ApiResult<void>> playTrack(String trackId, {num? startTime});
  Future<ApiResult<void>> pauseTrack();
  Future<ApiResult<void>> seekTrack(num time);
  Future<ApiResult<String>> nextTrack();
  Future<ApiResult<String>> previousTrack();
  Future<ApiResult<void>> setTimer(int minutes);
  Future<ApiResult<MusicLibraryResponse>> getMusicLibrary({
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<ApiResult<Track>> addTrackFromLibrary(String trackId);
}
