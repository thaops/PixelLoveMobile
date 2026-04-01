import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/leaderboard/data/datasoucres/leaderboard_remote_datasoucre.dart';
import 'package:pixel_love/features/leaderboard/data/models/leaderboard_dto.dart';
import 'package:pixel_love/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDatasoucre _remoteDatasoucre;
  LeaderboardRepositoryImpl(this._remoteDatasoucre);

  @override
  Future<ApiResult<LeaderboardDto>> getLeaderboard() async {
    return await _remoteDatasoucre.getLeaderboard();
  }

  @override
  Future<ApiResult<CoupleDetailDto>> getCoupleDetail(String coupleId) async {
    return await _remoteDatasoucre.getCoupleDetail(coupleId);
  }

  @override
  Future<ApiResult<HeartResponseDto>> sendHeart(String coupleId) async {
    return await _remoteDatasoucre.sendHeart(coupleId);
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> uploadGalleryImage(
    String imageUrl,
  ) async {
    return await _remoteDatasoucre.uploadGalleryImage(imageUrl);
  }
}