import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';

class AuthLoginResponse {
  final AuthUser user;
  final String token;
  final bool needProfile;

  AuthLoginResponse({
    required this.user,
    required this.token,
    required this.needProfile,
  });
}

