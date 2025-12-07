import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';
import 'package:pixel_love/features/auth/domain/repositories/auth_repository.dart';

class GetMeUseCase {
  final AuthRepository _repository;

  GetMeUseCase(this._repository);

  Future<ApiResult<AuthUser>> call() async {
    return await _repository.getMe();
  }
}

