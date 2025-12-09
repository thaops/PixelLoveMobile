import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';
import 'package:pixel_love/features/home/domain/repositories/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository _repository;

  GetHomeDataUseCase(this._repository);

  Future<ApiResult<Home>> call() {
    return _repository.getHomeData();
  }
}

