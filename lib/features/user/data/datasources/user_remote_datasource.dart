import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/user/data/models/user_dto.dart';

abstract class UserRemoteDataSource {
  Future<ApiResult<UserDto>> completeProfile({
    required String name,
    required String dob,
  });
  Future<ApiResult<UserDto>> updateProfile(Map<String, dynamic> data);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioApi _dioApi;

  UserRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<UserDto>> completeProfile({
    required String name,
    required String dob,
  }) async {
    return await _dioApi.post(
      '/auth/update-profile',
      data: {
        'name': name,
        'dob': dob,
      },
      fromJson: (json) {
        final userData = json['user'] ?? json;
        return UserDto.fromJson(userData);
      },
    );
  }

  @override
  Future<ApiResult<UserDto>> updateProfile(Map<String, dynamic> data) async {
    return await _dioApi.put(
      '/user/update',
      data: data,
      fromJson: (json) => UserDto.fromJson(json),
    );
  }
}
