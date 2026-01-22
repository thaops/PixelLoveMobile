import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/couple/domain/entities/couple_code.dart';
import 'package:pixel_love/features/couple/domain/entities/partner_preview.dart';
import 'package:pixel_love/features/couple/providers/couple_providers.dart';

/// Couple Connection State
class CoupleConnectionState {
  final bool isLoading;
  final String? errorMessage;
  final CoupleCode? coupleCode;
  final String inputCode;
  final PartnerPreview? partnerPreview;
  final bool canConnect;

  const CoupleConnectionState({
    this.isLoading = false,
    this.errorMessage,
    this.coupleCode,
    this.inputCode = '',
    this.partnerPreview,
    this.canConnect = false,
  });

  CoupleConnectionState copyWith({
    bool? isLoading,
    String? errorMessage,
    CoupleCode? coupleCode,
    String? inputCode,
    PartnerPreview? partnerPreview,
    bool? canConnect,
  }) {
    return CoupleConnectionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      coupleCode: coupleCode ?? this.coupleCode,
      inputCode: inputCode ?? this.inputCode,
      partnerPreview: partnerPreview ?? this.partnerPreview,
      canConnect: canConnect ?? this.canConnect,
    );
  }
}

/// Couple Connection Notifier - Handles couple connection logic
class CoupleConnectionNotifier extends Notifier<CoupleConnectionState> {
  Timer? _debounceTimer;

  @override
  CoupleConnectionState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // Setup socket listeners
    _setupSocketListeners();

    // Check and initialize after build completes
    // Use Future.microtask to avoid reading state before initialization
    Future.microtask(() {
      _checkAndInitialize();
    });

    return const CoupleConnectionState();
  }

  void _setupSocketListeners() {
    final socketService = ref.read(socketServiceProvider);

    // Ensure we are connected to the events socket
    socketService.connectEvents();

    socketService.onCouplePaired = (data) {
      _handleCouplePaired(data);
    };

    socketService.onCoupleRoomUpdated = (data) {
      // Có thể update UI nếu cần
    };

    socketService.onCoupleBrokenUp = (data) {
      // Navigation sẽ được handle ở UI layer
    };
  }

  void _handleCouplePaired(Map<String, dynamic> data) {
    final partner = data['partner'] as Map<String, dynamic>?;
    if (partner != null) {
      // Navigation sẽ được handle ở UI layer thông qua ref.listen
    }
  }

  /// Kiểm tra xem user đã có coupleRoomId chưa trước khi tạo code
  void _checkAndInitialize() {
    final storageService = ref.read(storageServiceProvider);
    final authUser = storageService.getUser();
    final hasCoupleRoom =
        authUser?.coupleRoomId != null && authUser!.coupleRoomId!.isNotEmpty;
    final hasPartner =
        authUser?.partnerId != null && authUser!.partnerId!.isNotEmpty;

    // Nếu đã có coupleRoomId hoặc partnerId → đã kết nối
    // Navigation sẽ được handle ở UI layer
    if (hasCoupleRoom || hasPartner) {
      print('⚠️ User đã có coupleRoomId/partnerId');
      return;
    }

    // Chưa có → tạo code mới
    _createCode();
  }

  void setInputCode(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    state = state.copyWith(inputCode: value);
    final isValidLength = value.trim().length >= 6;
    state = state.copyWith(canConnect: isValidLength);

    if (isValidLength) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _previewCode(value.trim());
      });
    } else {
      state = state.copyWith(partnerPreview: null);
    }
  }

  Future<void> _createCode() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final createCodeUseCase = ref.read(createCodeUseCaseProvider);
      final result = await createCodeUseCase.call();

      result.when(
        success: (code) {
          state = state.copyWith(coupleCode: code, isLoading: false);
        },
        error: (error) {
          // Xử lý lỗi 400 - đã kết nối rồi
          if (error.message.contains('already connected') ||
              error.message.contains('400')) {
            print('⚠️ User đã kết nối');
            state = state.copyWith(errorMessage: null, isLoading: false);
            // Navigation sẽ được handle ở UI layer
          } else {
            state = state.copyWith(
              errorMessage: error.message,
              isLoading: false,
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Lỗi tạo mã: $e', isLoading: false);
    }
  }

  Future<void> _previewCode(String code) async {
    try {
      final previewCodeUseCase = ref.read(previewCodeUseCaseProvider);
      final result = await previewCodeUseCase.call(code);

      result.when(
        success: (preview) {
          state = state.copyWith(
            partnerPreview: preview,
            // Update canConnect based on preview result if available
            canConnect: preview.canPair,
          );
        },
        error: (error) {
          state = state.copyWith(
            partnerPreview: null,
            // Keep existing canConnect state (true if length valid) to allow user to try and fail explicitly
          );
        },
      );
    } catch (e) {
      print('❌ Preview exception: $e');
    }
  }

  Future<void> copyCode() async {
    if (state.coupleCode == null) return;
    // Copy logic sẽ được handle ở UI layer
  }

  Future<void> shareCode() async {
    if (state.coupleCode == null) return;
    // Share logic sẽ được handle ở UI layer
  }

  Future<void> connect() async {
    if (!state.canConnect || state.inputCode.trim().isEmpty) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final pairCoupleUseCase = ref.read(pairCoupleUseCaseProvider);
      final result = await pairCoupleUseCase.call(state.inputCode.trim());

      result.when(
        success: (response) async {
          // Update local user data
          final storageService = ref.read(storageServiceProvider);
          final currentUser = storageService.getUser();

          if (currentUser != null) {
            final updatedUser = currentUser.copyWith(
              coupleRoomId: response.coupleRoomId,
              partnerId: response.partnerId,
            );
            await storageService.saveUser(updatedUser);
          }

          state = state.copyWith(isLoading: false);
          // Navigation will be handled by UI layer listening to state/storage changes
        },
        error: (error) {
          state = state.copyWith(errorMessage: error.message, isLoading: false);
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Lỗi kết nối: $e', isLoading: false);
    }
  }

  void scanQR() {
    // QR scan logic sẽ được handle ở UI layer
  }
}

/// Provider để cleanup socket listeners khi notifier bị dispose
final coupleConnectionNotifierDisposerProvider = Provider<void>((ref) {
  ref.onDispose(() {
    final socketService = ref.read(socketServiceProvider);
    socketService.onCouplePaired = null;
    socketService.onCoupleRoomUpdated = null;
    socketService.onCoupleBrokenUp = null;
  });
});
