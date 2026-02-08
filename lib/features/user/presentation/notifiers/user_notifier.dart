import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/user/domain/entities/user.dart';
import 'package:pixel_love/features/user/providers/user_providers.dart';

/// User State
class UserState {
  final bool isLoading;
  final String? errorMessage;
  final User? currentUser;

  const UserState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
  });

  UserState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? currentUser,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

/// User Notifier - Handles user profile operations
class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    // Load user from storage after build completes
    // Use Future.microtask to avoid reading state before initialization
    Future.microtask(() {
      _loadUserFromStorage();
    });
    return const UserState();
  }

  void _loadUserFromStorage() {
    final storageService = ref.read(storageServiceProvider);
    final authUser = storageService.getUser();
    if (authUser != null) {
      // Convert AuthUser to User entity
      final user = User(
        id: authUser.id,
        name: authUser.name,
        avatar: authUser.avatar,
        email: authUser.email,
        phone: null,
        dob: authUser.dob,
        zodiac: authUser.zodiac,
        mode: authUser.mode,
        coupleCode: authUser.coupleCode,
        coupleRoomId: authUser.coupleRoomId,
        coins: authUser.coins,
        createdAt: null,
      );
      state = state.copyWith(currentUser: user);
    }
  }

  // For refreshing user data
  Future<void> fetchProfile() async {
    _loadUserFromStorage();
  }

  // Complete profile flow (after first login)
  Future<void> completeProfile({
    required String name,
    required String dob,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final completeProfileUseCase = ref.read(completeProfileUseCaseProvider);
      final result = await completeProfileUseCase.call(name: name, dob: dob);

      result.when(
        success: (user) {
          print('✅ Profile completed: ${user.name}, zodiac=${user.zodiac}');
          state = state.copyWith(currentUser: user, isLoading: false);
          // Navigation sẽ được handle ở UI layer
        },
        error: (error) {
          state = state.copyWith(errorMessage: error.message, isLoading: false);
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Unexpected error: $e',
        isLoading: false,
      );
    }
  }

  Future<void> updateProfile({
    String? name,
    String? avatar,
    String? email,
    String? phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (avatar != null) data['avatar'] = avatar;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;

      final updateProfileUseCase = ref.read(updateProfileUseCaseProvider);
      final result = await updateProfileUseCase.call(data);

      result.when(
        success: (user) {
          state = state.copyWith(currentUser: user, isLoading: false);
          // Navigation và snackbar sẽ được handle ở UI layer
        },
        error: (error) {
          state = state.copyWith(errorMessage: error.message, isLoading: false);
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Unexpected error: $e',
        isLoading: false,
      );
    }
  }

  Future<void> leaveCouple() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final leaveCoupleUseCase = ref.read(leaveCoupleUseCaseProvider);
      final result = await leaveCoupleUseCase.call();

      result.when(
        success: (_) {
          // Refresh user data from storage
          _loadUserFromStorage();
          state = state.copyWith(isLoading: false);
        },
        error: (error) {
          state = state.copyWith(errorMessage: error.message, isLoading: false);
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Unexpected error: $e',
        isLoading: false,
      );
    }
  }
}
