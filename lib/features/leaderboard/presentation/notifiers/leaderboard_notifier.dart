import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/leaderboard/data/models/leaderboard_dto.dart';
import 'package:pixel_love/features/leaderboard/domain/entities/leaderboard.dart';
import 'package:pixel_love/features/leaderboard/provider/leaderboard_provider.dart';

class LeaderboardState {
  final Leaderboard? leaderboard;
  final bool isLoading;
  final String? errorMessage;
  final CoupleDetailDto? currentCoupleDetail;
  final bool isDetailLoading;

  const LeaderboardState({
    this.leaderboard,
    this.isLoading = false,
    this.errorMessage,
    this.currentCoupleDetail,
    this.isDetailLoading = false,
  });

  LeaderboardState copyWith({
    Leaderboard? leaderboard,
    bool? isLoading,
    String? errorMessage,
    CoupleDetailDto? currentCoupleDetail,
    bool? isDetailLoading,
    bool clearError = false,
  }) {
    return LeaderboardState(
      leaderboard: leaderboard ?? this.leaderboard,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentCoupleDetail: currentCoupleDetail ?? this.currentCoupleDetail,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
    );
  }
}

class LeaderboardNotifier extends Notifier<LeaderboardState> {
  @override
  LeaderboardState build() {
    Future.microtask(() => getLeaderboard());
    return const LeaderboardState();
  }

  Future<void> getLeaderboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repository = ref.read(leaderboardRepositoryProvider);
    final result = await repository.getLeaderboard();

    result.when(
      success: (dto) {
        state = state.copyWith(
          isLoading: false,
          leaderboard: dto.toEntity(),
        );
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> getCoupleDetail(String coupleId) async {
    state = state.copyWith(isDetailLoading: true);
    final repository = ref.read(leaderboardRepositoryProvider);
    final result = await repository.getCoupleDetail(coupleId);

    result.when(
      success: (dto) {
        state = state.copyWith(
          isDetailLoading: false,
          currentCoupleDetail: dto,
        );
      },
      error: (error) {
        state = state.copyWith(
          isDetailLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> sendHeart(String coupleId) async {
    final repository = ref.read(leaderboardRepositoryProvider);
    final result = await repository.sendHeart(coupleId);

    result.when(
      success: (dto) {
        if (dto.success) {
          // Refresh leaderboard to see updated LP Score
          getLeaderboard();
          // Also refresh detail if current visible couple is this one
          if (state.currentCoupleDetail?.coupleId == coupleId) {
            getCoupleDetail(coupleId);
          }
        }
      },
      error: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
  }

  Future<void> uploadGalleryImage(String imageUrl) async {
    final repository = ref.read(leaderboardRepositoryProvider);
    final result = await repository.uploadGalleryImage(imageUrl);

    result.when(
      success: (data) {
        // Refresh current detail if visible to show new image
        if (state.currentCoupleDetail != null) {
          getCoupleDetail(state.currentCoupleDetail!.coupleId);
        }
      },
      error: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
  }
}
