import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/auth/providers/auth_providers.dart';
import 'package:pixel_love/features/user/providers/user_providers.dart';

/// Settings State
class SettingsState {
  final bool isLoading;
  final String? errorMessage;

  const SettingsState({
    this.isLoading = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Settings Notifier - Handles settings operations
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState();
  }

  Future<void> deleteAccount() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final storageService = ref.read(storageServiceProvider);
      final user = storageService.getUser();
      if (user == null) {
        state = state.copyWith(
          errorMessage: 'Không tìm thấy thông tin người dùng',
          isLoading: false,
        );
        return;
      }

      final deleteAccountUseCase = ref.read(deleteAccountUseCaseProvider);
      final result = await deleteAccountUseCase.call(user.id);

      if (result.isSuccess) {
        // Sign out from Google
        final googleSignIn = ref.read(googleSignInProvider);
        await googleSignIn.signOut();
        
        // Disconnect socket
        final socketService = ref.read(socketServiceProvider);
        socketService.disconnectEvents();
        
        // Clear all data
        await storageService.clearAll();
        
        state = state.copyWith(isLoading: false);
        // Navigation sẽ được handle ở UI layer
      } else if (result.error != null) {
        state = state.copyWith(
          errorMessage: result.error!.message,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Lỗi xóa tài khoản: $e',
        isLoading: false,
      );
    }
  }
}

