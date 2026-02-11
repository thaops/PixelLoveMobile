import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/auth/notifiers/auth_state.dart';
import 'package:pixel_love/features/auth/providers/auth_providers.dart';
import 'package:pixel_love/core/services/notification_service.dart';

/// Auth Notifier - Handles authentication logic
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
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

      await ref.read(googleSignInInitProvider.future);
      final googleSignIn = ref.read(googleSignInProvider);
      final loginGoogleUseCase = ref.read(loginGoogleUseCaseProvider);
      final storageService = ref.read(storageServiceProvider);
      final socketService = ref.read(socketServiceProvider);

      final googleUser = await googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );

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

        final getMeUseCase = ref.read(getMeUseCaseProvider);
        final getMeResult = await getMeUseCase.call();

        await getMeResult.when(
          success: (fullUser) async {
            await storageService.saveUser(fullUser);

            state = state.copyWith(
              isLoading: false,
              currentUser: fullUser,
              needProfile: response.needProfile,
            );

            await socketService.connectEvents();
            await NotificationService.login(fullUser.id);
          },
          error: (error) async {
            state = state.copyWith(
              isLoading: false,
              currentUser: response.user,
              needProfile: response.needProfile,
            );
            await storageService.saveUser(response.user);
            await socketService.connectEvents();
          },
        );
      } else if (result.error != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error!.message,
        );
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Google sign in cancelled',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google login error: ${e.code.name}',
      );
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

      await result.when(
        success: (user) async {
          final token = storageService.getToken() ?? '';
          final userWithToken = user.copyWith(accessToken: token);

          await storageService.saveUser(userWithToken);

          state = state.copyWith(isLoading: false, currentUser: userWithToken);
        },
        error: (error) {
          state = state.copyWith(isLoading: false, errorMessage: error.message);
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
    await ref.read(googleSignInInitProvider.future);
    final googleSignIn = ref.read(googleSignInProvider);
    final socketService = ref.read(socketServiceProvider);

    await logoutUseCase.call();
    await googleSignIn.signOut();
    socketService.disconnectEvents();
    NotificationService.logout();

    state = const AuthState(currentUser: null, needProfile: false);
  }
}
