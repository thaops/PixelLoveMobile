import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/leaderboard/data/models/leaderboard_dto.dart';
import 'package:pixel_love/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class GetLeaderboardUsecase {
  final LeaderboardRepository _repository;
  GetLeaderboardUsecase(this._repository);

  Future<ApiResult<LeaderboardDto>> call() async {
    return await _repository.getLeaderboard();
  }
}
