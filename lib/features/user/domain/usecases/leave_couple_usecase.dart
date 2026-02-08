import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/user/domain/repositories/user_repository.dart';

class LeaveCoupleUseCase {
  final UserRepository _repository;

  LeaveCoupleUseCase(this._repository);

  Future<ApiResult<void>> call() {
    return _repository.leaveCouple();
  }
}
