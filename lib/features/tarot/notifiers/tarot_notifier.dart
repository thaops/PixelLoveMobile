import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/tarot/data/models/tarot_response.dart';
import 'package:pixel_love/features/tarot/notifiers/tarot_state.dart';
import 'package:pixel_love/features/tarot/providers/tarot_providers.dart';

class TarotNotifier extends Notifier<TarotState> {
  Timer? _countdownTimer;

  @override
  TarotState build() {
    _initSocket();
    ref.onDispose(() {
      final socketService = ref.read(socketServiceProvider);
      socketService.onTarotSelected = null;
      socketService.onTarotReady = null;
      socketService.onTarotReveal = null;
      _countdownTimer?.cancel();
    });
    return const TarotState();
  }

  void _initSocket() {
    final socketService = ref.read(socketServiceProvider);

    socketService.onTarotSelected = (data) {
      state = state.copyWith(partnerSelected: true);
    };

    socketService.onTarotReady = (data) {
      _startCountdown();
    };

    socketService.onTarotReveal = (data) {
      final result = TarotResult.fromJson(data);
      state = state.copyWith(status: TarotStatus.REVEALED, result: result);
    };
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    state = state.copyWith(status: TarotStatus.READY, countdown: 3);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown > 1) {
        state = state.copyWith(countdown: state.countdown - 1);
      } else {
        timer.cancel();
        state = state.copyWith(countdown: 0);
        revealTarot();
      }
    });
  }

  Future<void> syncStatus() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final repo = ref.read(tarotRepositoryProvider);
      final result = await repo.getTodayTarot();

      result.when(
        success: (response) {
          state = state.copyWith(
            isLoading: false,
            status: response.status,
            myCard: response.myCard,
            partnerSelected: response.partnerSelected,
            result: response.result,
          );

          if (response.status == TarotStatus.READY) {
            revealTarot();
          }
        },
        error: (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectCard(int cardId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final repo = ref.read(tarotRepositoryProvider);
      final result = await repo.selectCard(cardId);

      result.when(
        success: (response) {
          state = state.copyWith(
            isLoading: false,
            status: response.status,
            myCard: response.myCard,
            partnerSelected: response.partnerSelected,
          );

          if (response.status == TarotStatus.READY) {
            _startCountdown();
          }
        },
        error: (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> revealTarot() async {
    try {
      final repo = ref.read(tarotRepositoryProvider);
      final result = await repo.revealTarot();

      result.when(
        success: (tarotResult) {
          state = state.copyWith(
            status: TarotStatus.REVEALED,
            result: tarotResult,
          );
        },
        error: (failure) {
          state = state.copyWith(errorMessage: failure.message);
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
