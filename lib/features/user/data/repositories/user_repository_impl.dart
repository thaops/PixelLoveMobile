import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';
import 'package:pixel_love/features/user/data/datasources/user_remote_datasource.dart';
import 'package:pixel_love/features/user/domain/entities/user.dart';
import 'package:pixel_love/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final StorageService _storageService;

  UserRepositoryImpl(this._remoteDataSource, this._storageService);

  @override
  Future<ApiResult<User>> completeProfile({
    required String name,
    required String dob,
  }) async {
    final result = await _remoteDataSource.completeProfile(
      name: name,
      dob: dob,
    );

    return result.when(
      success: (dto) {
        final user = dto.toEntity();

        // Get current token from storage
        final token = _storageService.getToken() ?? '';

        // Get existing AuthUser to preserve accessToken
        final existingAuthUser = _storageService.getUser();

        // Create/Update AuthUser with new user data
        final authUser = AuthUser(
          id: user.id,
          name: user.name,
          email: user.email,
          avatar: user.avatar,
          dob: user.dob,
          zodiac: user.zodiac,
          mode: user.mode,
          coupleCode: user.coupleCode,
          coupleRoomId: user.coupleRoomId,
          coins: user.coins,
          accessToken: existingAuthUser?.accessToken ?? token,
        );

        // Save updated user to storage
        _storageService.saveUser(authUser);

        return ApiResult.success(user);
      },
      error: (error) => ApiResult.error(error),
    );
  }

  @override
  Future<ApiResult<User>> updateProfile(Map<String, dynamic> data) async {
    final result = await _remoteDataSource.updateProfile(data);

    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (error) => ApiResult.error(error),
    );
  }
}
