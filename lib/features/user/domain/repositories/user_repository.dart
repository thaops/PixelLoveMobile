import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/user/domain/entities/user.dart';

abstract class UserRepository {
  Future<ApiResult<User>> completeProfile({
    required String name,
    required String dob,
  });
  Future<ApiResult<User>> updateProfile(Map<String, dynamic> data);
  Future<ApiResult<User>> onboard({
    required String nickname,
    required String gender,
    required String birthDate,
  });
  Future<ApiResult<void>> deleteAccount(String userId);
}
