import 'package:pixel_love/features/auth/data/models/auth_user_dto.dart';

class AuthResponseDto {
  final String token;
  final AuthUserDto user;
  final bool needProfile;

  AuthResponseDto({
    required this.token,
    required this.user,
    required this.needProfile,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    final token =
        json['accessToken'] ?? json['token'] ?? json['access_token'] ?? '';

    if (userData is Map<String, dynamic>) {
      userData['token'] = token;
      userData['accessToken'] = token;
      userData['access_token'] = token;
    }

    return AuthResponseDto(
      token: token,
      user: AuthUserDto.fromJson(userData),
      needProfile: json['needProfile'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson(), 'needProfile': needProfile};
  }
}
