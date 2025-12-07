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
    // Handle nested user object
    final userData = json['user'] ?? json;

    return AuthResponseDto(
      token: json['accessToken'] ?? json['token'] ?? json['access_token'] ?? '',
      user: AuthUserDto.fromJson(userData),
      needProfile: json['needProfile'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson(), 'needProfile': needProfile};
  }
}
