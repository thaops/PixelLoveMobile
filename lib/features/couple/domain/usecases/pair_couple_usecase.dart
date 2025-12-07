import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/couple/domain/entities/couple_pair_response.dart';
import 'package:pixel_love/features/couple/domain/repositories/couple_repository.dart';

class PairCoupleUseCase {
  final CoupleRepository _repository;

  PairCoupleUseCase(this._repository);

  Future<ApiResult<CouplePairResponse>> call(String code) async {
    return await _repository.pairCouple(code);
  }
}

