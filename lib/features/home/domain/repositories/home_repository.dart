import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';

abstract class HomeRepository {
  Future<ApiResult<Home>> getHomeData();
}

