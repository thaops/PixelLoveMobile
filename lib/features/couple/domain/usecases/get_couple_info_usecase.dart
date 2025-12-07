import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/couple/domain/repositories/couple_repository.dart';

class GetCoupleInfoUseCase {
  final CoupleRepository _repository;

  GetCoupleInfoUseCase(this._repository);

  Future<ApiResult<Map<String, dynamic>>> call() async {
    return await _repository.getCoupleInfo();
  }
}

