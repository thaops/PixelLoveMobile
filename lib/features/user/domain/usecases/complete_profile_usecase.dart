import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/user/domain/entities/user.dart';
import 'package:pixel_love/features/user/domain/repositories/user_repository.dart';

class CompleteProfileUseCase {
  final UserRepository _repository;

  CompleteProfileUseCase(this._repository);

  Future<ApiResult<User>> call({
    required String name,
    required String dob,
  }) async {
    return await _repository.completeProfile(name: name, dob: dob);
  }
}

