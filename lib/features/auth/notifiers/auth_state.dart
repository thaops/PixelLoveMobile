import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';

/// Auth State - Quản lý trạng thái authentication
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final AuthUser? currentUser;
  final bool needProfile;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
    this.needProfile = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    AuthUser? currentUser,
    bool? needProfile,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentUser: currentUser ?? this.currentUser,
      needProfile: needProfile ?? this.needProfile,
    );
  }
}
