import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/tarot/data/models/tarot_response.dart';
import 'package:pixel_love/features/tarot/notifiers/tarot_state.dart';
import 'package:pixel_love/features/tarot/providers/tarot_providers.dart';
import 'package:pixel_love/features/user/providers/user_providers.dart';

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

    // Đảm bảo kết nối socket
    socketService.connectEvents();

    // Join room nếu đã có coupleRoomId
    final currentUser = ref.read(userNotifierProvider).currentUser;
    if (currentUser?.coupleRoomId != null) {
      socketService.joinCoupleRoom(currentUser!.coupleRoomId!);
    }

    socketService.onTarotSelected = (data) {
      final currentUserId = ref.read(userNotifierProvider).currentUser?.id;
      final byId = data['by'] as String?;
      
      print('🔮 [Socket] tarotSelected received from: $byId (Me: $currentUserId)');
      
      if (byId != null && byId != currentUserId) {
        state = state.copyWith(partnerSelected: true);
        
        // Nếu mình cũng đã chọn bài rồi (myCard != null), thì tự động chuyển sang READY và gọi API Reveal
        if (state.myCard != null) {
          print('🔮 Both selected! Switching to READY and revealing...');
          state = state.copyWith(status: TarotStatus.READY);
          revealTarot();
        }
      } else if (byId == currentUserId) {
        // Cập nhật trạng thái của chính mình nếu cần (thường đã được handle bởi API call)
        print('🔮 [Socket] tarotSelected from Me - Already handled or syncing...');
      }
    };

    socketService.onTarotReady = (data) {
      print('🔮 [Socket] tarotReady! Automatically revealing results...');
      // Khi server báo Ready, luôn gọi Reveal để lấy kết quả AI
      revealTarot();
    };

    socketService.onTarotReveal = (data) {
      print('🔮 [Socket] tarotReveal received with data: $data');
      
      // Chấp nhận kết quả từ Server bất kể ai kích hoạt để đảm bảo đồng bộ
      final result = TarotResult.fromJson(data);
      state = state.copyWith(
        status: TarotStatus.REVEALED, 
        result: result,
        isLoading: false,
      );
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
