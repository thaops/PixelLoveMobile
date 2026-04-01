import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/leaderboard/data/models/leaderboard_dto.dart';

abstract class LeaderboardRemoteDatasoucre {
  Future<ApiResult<LeaderboardDto>> getLeaderboard();
  Future<ApiResult<CoupleDetailDto>> getCoupleDetail(String coupleId);
  Future<ApiResult<HeartResponseDto>> sendHeart(String coupleId);
  Future<ApiResult<Map<String, dynamic>>> uploadGalleryImage(String imageUrl);
}

class LeaderboardRemoteDatasoucreImpl implements LeaderboardRemoteDatasoucre {
  final DioApi _dioApi;
  LeaderboardRemoteDatasoucreImpl(this._dioApi);

  @override
  Future<ApiResult<LeaderboardDto>> getLeaderboard() async {
    return await _dioApi.get(
      "/pet/leaderboard",
      fromJson: (json) => LeaderboardDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<CoupleDetailDto>> getCoupleDetail(String coupleId) async {
    return await _dioApi.get(
      "/couple/detail/$coupleId",
      fromJson: (json) => CoupleDetailDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<HeartResponseDto>> sendHeart(String coupleId) async {
    return await _dioApi.post(
      "/couple/heart/$coupleId",
      fromJson: (json) => HeartResponseDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> uploadGalleryImage(
    String imageUrl,
  ) async {
    return await _dioApi.post(
      "/couple/gallery/upload",
      data: {"imageUrl": imageUrl},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
