import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';
import 'package:pixel_love/features/auth/providers/auth_providers.dart';

/// Auth State
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

/// Auth Notifier - Handles authentication logic
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Load user from storage after build completes
    // Use Future.microtask to avoid reading state before initialization
    Future.microtask(() {
      _loadUserFromStorage();
    });
    return const AuthState();
  }

  void _loadUserFromStorage() {
    final storageService = ref.read(storageServiceProvider);
    final user = storageService.getUser();
    if (user != null) {
      state = state.copyWith(currentUser: user);
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final googleSignIn = ref.read(googleSignInProvider);
      final loginGoogleUseCase = ref.read(loginGoogleUseCaseProvider);
      final storageService = ref.read(storageServiceProvider);
      final socketService = ref.read(socketServiceProvider);

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Google sign in cancelled',
        );
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to get Google access token',
        );
        return;
      }

      final result = await loginGoogleUseCase.call(idToken);

      if (result.isSuccess && result.data != null) {
        final response = result.data!;

        await storageService.saveToken(response.token);

        state = state.copyWith(
          isLoading: false,
          currentUser: response.user,
          needProfile: response.needProfile,
        );
        
        await storageService.saveUser(response.user);
        await socketService.connectEvents();
      } else if (result.error != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error!.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google login error: $e',
      );
    }
  }

  Future<void> getMe() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final getMeUseCase = ref.read(getMeUseCaseProvider);
      final storageService = ref.read(storageServiceProvider);

      final result = await getMeUseCase.call();

      result.when(
        success: (user) {
          state = state.copyWith(
            isLoading: false,
            currentUser: user,
          );
          storageService.saveUser(user);
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: error.message,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Get me error: $e',
      );
    }
  }

  Future<void> logout() async {
    final logoutUseCase = ref.read(logoutUseCaseProvider);
    final googleSignIn = ref.read(googleSignInProvider);
    final socketService = ref.read(socketServiceProvider);

    await logoutUseCase.call();
    await googleSignIn.signOut();
    socketService.disconnectEvents();

    state = const AuthState(
      currentUser: null,
      needProfile: false,
    );
  }
}

