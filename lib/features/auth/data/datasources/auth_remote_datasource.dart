import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/auth/data/models/auth_response_dto.dart';
import 'package:pixel_love/features/auth/data/models/auth_user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResult<AuthResponseDto>> loginGoogle(String accessToken);
  Future<ApiResult<AuthUserDto>> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioApi _dioApi;

  AuthRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<AuthResponseDto>> loginGoogle(String accessToken) async {
    return await _dioApi.post(
      '/auth/google',
      data: {'idToken': accessToken},
      fromJson: (json) => AuthResponseDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<AuthUserDto>> getMe() async {
    return await _dioApi.get(
      '/users/me',
      fromJson: (json) {
        final userData = json['user'] ?? json;
        return AuthUserDto.fromJson(userData);
      },
    );
  }
}
