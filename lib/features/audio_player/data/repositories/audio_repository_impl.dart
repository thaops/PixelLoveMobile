import 'package:pixel_love/core/network/api_result.dart';
import '../datasources/audio_remote_datasource.dart';
import '../../domain/entities/audio_player_state.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/paginated_queue_response.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../domain/entities/music_library_response.dart';

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
  Future<ApiResult<Track>> addTrack({required String youtubeUrl}) async {
    final result = await _remoteDataSource.addTrack(youtubeUrl: youtubeUrl);
    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (failure) => ApiResult.error(failure),
    );
  }

  @override
  Future<ApiResult<void>> removeTrack(String trackId) async {
    return _remoteDataSource.removeTrack(trackId);
  }

  @override
  Future<ApiResult<PaginatedQueueResponse>> getQueue({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final result = await _remoteDataSource.getQueue(
      page: page,
      limit: limit,
      search: search,
    );
    return result.when(
      success: (dto) => ApiResult.success(
        PaginatedQueueResponse(
          data: dto.data.map((e) => e.toEntity()).toList(),
          pagination: Pagination(
            total: dto.pagination.total,
            page: dto.pagination.page,
            limit: dto.pagination.limit,
            totalPages: dto.pagination.totalPages,
          ),
        ),
      ),
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

  @override
  Future<ApiResult<MusicLibraryResponse>> getMusicLibrary({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final result = await _remoteDataSource.getMusicLibrary(
      page: page,
      limit: limit,
      search: search,
    );
    return result.when(
      success: (dto) {
        return ApiResult.success(
          MusicLibraryResponse(
            data: dto.data.map((e) => e.toEntity()).toList(),
            pagination: Pagination(
              total: dto.pagination.total,
              page: dto.pagination.page,
              limit: dto.pagination.limit,
              totalPages: dto.pagination.totalPages,
            ),
          ),
        );
      },
      error: (failure) => ApiResult.error(failure),
    );
  }

  @override
  Future<ApiResult<Track>> addTrackFromLibrary(String trackId) async {
    final result = await _remoteDataSource.addTrackFromLibrary(trackId);
    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (failure) => ApiResult.error(failure),
    );
  }
}
