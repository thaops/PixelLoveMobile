import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/couple/domain/entities/couple_code.dart';
import 'package:pixel_love/features/couple/domain/repositories/couple_repository.dart';

class CreateCodeUseCase {
  final CoupleRepository _repository;

  CreateCodeUseCase(this._repository);

  Future<ApiResult<CoupleCode>> call() async {
    return await _repository.createCode();
  }
}

