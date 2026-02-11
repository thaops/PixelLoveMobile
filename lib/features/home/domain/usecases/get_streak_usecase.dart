import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/home/domain/entities/streak.dart';
import 'package:pixel_love/features/home/domain/repositories/home_repository.dart';

class GetStreakUseCase {
  final HomeRepository _repository;

  GetStreakUseCase(this._repository);

  Future<ApiResult<Streak>> execute() async {
    return await _repository.getStreak();
  }
}
