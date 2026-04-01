import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/leaderboard/data/models/leaderboard_dto.dart';

abstract class LeaderboardRepository {
  Future<ApiResult<LeaderboardDto>> getLeaderboard();
  Future<ApiResult<CoupleDetailDto>> getCoupleDetail(String coupleId);
  Future<ApiResult<HeartResponseDto>> sendHeart(String coupleId);
  Future<ApiResult<Map<String, dynamic>>> uploadGalleryImage(String imageUrl);
}
