import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/auth/data/models/auth_login_response.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<ApiResult<AuthLoginResponse>> loginGoogle(String accessToken);
  Future<ApiResult<AuthUser>> getMe();
  Future<void> logout();
}
