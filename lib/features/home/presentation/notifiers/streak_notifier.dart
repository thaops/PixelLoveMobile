import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/home/domain/entities/streak.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';

class StreakState extends Equatable {
  final Streak? streak;
  final bool isLoading;
  final String? errorMessage;

  const StreakState({this.streak, this.isLoading = false, this.errorMessage});

  StreakState copyWith({
    Streak? streak,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StreakState(
      streak: streak ?? this.streak,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [streak, isLoading, errorMessage];
}

class StreakNotifier extends Notifier<StreakState> {
  @override
  StreakState build() {
    return const StreakState();
  }

  Future<void> fetchStreak() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(getStreakUseCaseProvider);
    final result = await useCase.execute();

    result.when(
      success: (streak) {
        state = state.copyWith(streak: streak, isLoading: false);
      },
      error: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }
}
