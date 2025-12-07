import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/user/domain/entities/user.dart';
import 'package:pixel_love/features/user/domain/repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<ApiResult<User>> call(Map<String, dynamic> data) {
    return _repository.updateProfile(data);
  }
}
