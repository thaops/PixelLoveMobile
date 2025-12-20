import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/user/providers/user_providers.dart';

/// Onboard State
class OnboardState {
  final bool isLoading;
  final String? errorMessage;
  final String? selectedGender;
  final DateTime? selectedBirthDate;
  final String nickname;

  const OnboardState({
    this.isLoading = false,
    this.errorMessage,
    this.selectedGender = 'female', // Default to female
    this.selectedBirthDate,
    this.nickname = '',
  });

  bool get canSubmit =>
      nickname.trim().isNotEmpty &&
      selectedGender != null &&
      selectedBirthDate != null;

  OnboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? selectedGender,
    DateTime? selectedBirthDate,
    String? nickname,
  }) {
    return OnboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedBirthDate: selectedBirthDate ?? this.selectedBirthDate,
      nickname: nickname ?? this.nickname,
    );
  }
}

/// Onboard Notifier - Handles onboarding flow
class OnboardNotifier extends Notifier<OnboardState> {
  @override
  OnboardState build() {
    return const OnboardState();
  }

  void setGender(String gender) {
    state = state.copyWith(selectedGender: gender);
  }

  void setBirthDate(DateTime date) {
    state = state.copyWith(selectedBirthDate: date);
  }

  void setNickname(String value) {
    state = state.copyWith(nickname: value);
  }

  Future<void> submit() async {
    if (!state.canSubmit) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final birthDateString =
          '${state.selectedBirthDate!.year}-${state.selectedBirthDate!.month.toString().padLeft(2, '0')}-${state.selectedBirthDate!.day.toString().padLeft(2, '0')}';

      final onboardUseCase = ref.read(onboardUseCaseProvider);
      final result = await onboardUseCase.call(
        nickname: state.nickname.trim(),
        gender: state.selectedGender!,
        birthDate: birthDateString,
      );

      result.when(
        success: (user) {
          state = state.copyWith(isLoading: false);
          // Navigation sẽ được handle ở UI layer
        },
        error: (error) {
          state = state.copyWith(
            errorMessage: error.message,
            isLoading: false,
          );
          // Navigation sẽ được handle ở UI layer
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

