import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/auth/data/models/auth_login_response.dart';
import 'package:pixel_love/features/auth/domain/repositories/auth_repository.dart';

class LoginGoogleUseCase {
  final AuthRepository _repository;

  LoginGoogleUseCase(this._repository);

  Future<ApiResult<AuthLoginResponse>> call(String accessToken) {
    return _repository.loginGoogle(accessToken);
  }
}
