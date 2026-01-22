import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/couple/domain/repositories/couple_repository.dart';

class BreakUpUseCase {
  final CoupleRepository _repository;

  BreakUpUseCase(this._repository);

  Future<ApiResult<void>> call() async {
    return await _repository.breakUp();
  }
}
