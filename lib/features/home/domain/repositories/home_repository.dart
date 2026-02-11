import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';
import 'package:pixel_love/features/home/domain/entities/streak.dart';

abstract class HomeRepository {
  Future<ApiResult<Home>> getHomeData();
  Future<ApiResult<Streak>> getStreak();
}
