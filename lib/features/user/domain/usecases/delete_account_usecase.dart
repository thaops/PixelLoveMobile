import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/user/domain/repositories/user_repository.dart';

class DeleteAccountUseCase {
  final UserRepository _repository;

  DeleteAccountUseCase(this._repository);

  Future<ApiResult<void>> call(String userId) async {
    return await _repository.deleteAccount(userId);
  }
}

