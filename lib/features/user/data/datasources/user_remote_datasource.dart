import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/user/data/models/user_dto.dart';

abstract class UserRemoteDataSource {
  Future<ApiResult<UserDto>> completeProfile({
    required String name,
    required String dob,
  });
  Future<ApiResult<UserDto>> updateProfile(Map<String, dynamic> data);
  Future<ApiResult<UserDto>> onboard({
    required String nickname,
    required String gender,
    required String birthDate,
  });
  Future<ApiResult<void>> deleteAccount(String userId);
  Future<ApiResult<void>> leaveCouple();
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
      data: {'name': name, 'dob': dob},
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

  @override
  Future<ApiResult<UserDto>> onboard({
    required String nickname,
    required String gender,
    required String birthDate,
  }) async {
    return await _dioApi.post(
      '/users/onboard',
      data: {'nickname': nickname, 'gender': gender, 'birthDate': birthDate},
      fromJson: (json) {
        final userData = json['user'] ?? json;
        return UserDto.fromJson(userData);
      },
    );
  }

  @override
  Future<ApiResult<void>> deleteAccount(String userId) async {
    return await _dioApi.delete('/users/$userId', fromJson: (json) => null);
  }

  @override
  Future<ApiResult<void>> leaveCouple() async {
    return await _dioApi.post(
      '/couple/break-up',
      data: {},
      fromJson: (json) => null,
    );
  }
}
