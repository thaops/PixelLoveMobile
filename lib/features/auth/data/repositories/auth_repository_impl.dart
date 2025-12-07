import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pixel_love/features/auth/data/models/auth_login_response.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';
import 'package:pixel_love/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final GetStorage _storage;

  AuthRepositoryImpl(this._remoteDataSource, this._storage);

  @override
  Future<ApiResult<AuthLoginResponse>> loginGoogle(String accessToken) async {
    final result = await _remoteDataSource.loginGoogle(accessToken);

    return result.when(
      success: (responseDto) {
        final user = responseDto.user.toEntity();
        
        // Save token
        _storage.write('access_token', responseDto.token);
        
        // Save user data
        _storage.write('user_data', jsonEncode(user.toJson()));
        
        return ApiResult.success(AuthLoginResponse(
          user: user,
          token: responseDto.token,
          needProfile: responseDto.needProfile,
        ));
      },
      error: (error) => ApiResult.error(error),
    );
  }

  @override
  Future<ApiResult<AuthUser>> getMe() async {
    final result = await _remoteDataSource.getMe();

    return result.when(
      success: (dto) {
        final user = dto.toEntity();
        _storage.write('user_data', jsonEncode(user.toJson()));
        return ApiResult.success(user);
      },
      error: (error) => ApiResult.error(error),
    );
  }

  @override
  Future<void> logout() async {
    await _storage.remove('access_token');
    await _storage.remove('user_data');
  }
}
