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
      print('🔮 [Socket] tarotSelected message received: $data');
      state = state.copyWith(partnerSelected: true);
    };

    socketService.onTarotReady = (data) {
      print('🔮 [Socket] tarotReady! Automatically revealing results...');
      revealTarot();
    };

    socketService.onTarotReveal = (data) {
      print('🔮 [Socket] tarotReveal received with data: $data');
      final result = TarotResult.fromJson(data);
      state = state.copyWith(status: TarotStatus.REVEALED, result: result);
    };
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
      state = state.copyWith(errorMessage: null);
      final repo = ref.read(tarotRepositoryProvider);
      final result = await repo.selectCard(cardId);

      result.when(
        success: (response) {
          state = state.copyWith(
            isLoading: false,
            status: response.status,
            myCard: response.myCard ?? cardId,
            partnerSelected: response.partnerSelected,
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

  Future<void> revealTarot() async {
    print('🚀 [TarotNotifier] Calling revealTarot API...');
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final repo = ref.read(tarotRepositoryProvider);
      final result = await repo.revealTarot();

      result.when(
        success: (tarotResult) {
          state = state.copyWith(
            isLoading: false,
            status: TarotStatus.REVEALED,
            result: tarotResult,
          );
        },
        error: (failure) {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> resetTarot() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final repo = ref.read(tarotRepositoryProvider);
      final result = await repo.resetTarot();

      result.when(
        success: (_) {
          state = const TarotState(); // Reset state locally
          syncStatus(); // Sync with server for fresh IDLE state
        },
        error: (failure) {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
