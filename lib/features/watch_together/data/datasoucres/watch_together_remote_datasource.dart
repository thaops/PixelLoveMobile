import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/watch_together/data/models/video_room_state_dto.dart';

abstract class WatchTogetherRemoteDataSource {
  Future<ApiResult<VideoRoomStateDto>> getVideoState();
  Future<ApiResult<bool>> addVideo(String url);
  Future<ApiResult<bool>> removeVideo(String itemId);
}

class WatchTogetherRemoteDataSourceImpl
    implements WatchTogetherRemoteDataSource {
  final DioApi _dioApi;

  WatchTogetherRemoteDataSourceImpl(this._dioApi);
  @override
  Future<ApiResult<bool>> addVideo(String url) {
    return _dioApi.post(
      '/player/video/add',
      data: {'url': url},
      fromJson: (json) => true,
    );
  }

  @override
  Future<ApiResult<VideoRoomStateDto>> getVideoState() {
    return _dioApi.get(
      '/player/video/state',
      fromJson: (json) =>
          VideoRoomStateDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<bool>> removeVideo(String itemId) {
    return _dioApi.delete(
      '/player/video/remove/$itemId',
      fromJson: (json) => true,
    );
  }
}
