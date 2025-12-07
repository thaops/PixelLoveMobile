import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/user/domain/entities/user.dart';
import 'package:pixel_love/features/user/domain/repositories/user_repository.dart';

class OnboardUseCase {
  final UserRepository _repository;

  OnboardUseCase(this._repository);

  Future<ApiResult<User>> call({
    required String nickname,
    required String gender,
    required String birthDate,
  }) async {
    return await _repository.onboard(
      nickname: nickname,
      gender: gender,
      birthDate: birthDate,
    );
  }
}

