import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_album_notifier.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart' as card_swiper;
import 'package:intl/intl.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/swipe_reaction_particle_overlay.dart';

class PetAlbumSwipeController {
  final TickerProvider vsync;
  final WidgetRef ref;
  final BuildContext Function() contextGetter;
  final VoidCallback onStateChanged;

  PetAlbumSwipeController({
    required this.vsync,
    required this.ref,
    required this.contextGetter,
    required this.onStateChanged,
  });

  final card_swiper.CardSwiperController swiperController =
      card_swiper.CardSwiperController();
  final ReactionParticleController reactionParticleController =
      ReactionParticleController();
  final Random random = Random();

  double verticalDragOffset = 0.0;
  bool _isDraggingVertically = false;

  int swipeCount = 0;
  bool showPartnerSignal = false;
  String? partnerSignalText;
  bool isHolding = false;
  bool showMemoryHighlight = false;
  String? memoryText;
  bool showEntryMessage = false;
  String? entryMessageText;
  bool _hasCheckedEntry = false;
  int _lastMemorySwipeCount = -10;

  // Logic Debounce Reaction
  final Map<String, Timer> _reactionDebounceTimers = {};
  final Map<String, int> _reactionPendingCounts = {};

  AnimationController? _partnerSignalController;
  AnimationController get partnerSignalController =>
      _partnerSignalController ??= AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 800),
      );

  AnimationController? _memoryHighlightController;
  AnimationController get memoryHighlightController =>
      _memoryHighlightController ??= AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 600),
      );

  AnimationController? _entryMessageController;
  AnimationController get entryMessageController =>
      _entryMessageController ??= AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 500),
      );

  late AnimationController shimmerController;
  late AnimationController fadeController;

  TemporaryCapturedImage? temporaryImage;

  Timer? _tapTimer;
  int _tapCount = 0;

  List<PetImage>? _cachedSortedImages;
  int _cachedImagesLength = -1;
  String _cachedFirstImageUrl = '';

  VoidCallback? onSessionEnding;

  void init() {
    shimmerController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    fadeController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 400),
    );
    fadeController.value = 1.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tempImage = ref.read(temporaryCapturedImageProvider);
      if (tempImage != null) {
        temporaryImage = tempImage;
        onStateChanged();
      }
    });
  }

  void dispose() {
    _tapTimer?.cancel();
    swiperController.dispose();
    _partnerSignalController?.dispose();
    _memoryHighlightController?.dispose();
    shimmerController.dispose();
    _entryMessageController?.dispose();
    fadeController.dispose();
    for (final timer in _reactionDebounceTimers.values) {
      timer.cancel();
    }
    _reactionDebounceTimers.clear();
  }

  String get currentUserId {
    final storageService = ref.read(storageServiceProvider);
    return storageService.getUser()?.id ?? '';
  }

  String? get partnerId {
    final storageService = ref.read(storageServiceProvider);
    return storageService.getUser()?.partnerId;
  }

  List<PetImage> getSortedImages(PetAlbumState albumState) {
    final newLength = albumState.images.length;
    final newFirstUrl = albumState.images.isNotEmpty
        ? albumState.images.first.imageUrl
        : '';
    if (_cachedSortedImages != null &&
        _cachedImagesLength == newLength &&
        _cachedFirstImageUrl == newFirstUrl) {
      return _cachedSortedImages!;
    }
    _cachedSortedImages = List<PetImage>.from(albumState.images)
      ..sort((a, b) => b.actionAt.compareTo(a.actionAt));
    _cachedImagesLength = newLength;
    _cachedFirstImageUrl = newFirstUrl;
    return _cachedSortedImages!;
  }

  void updateTemporaryImage(TemporaryCapturedImage? next) {
    temporaryImage = next;
    onStateChanged();
  }

  void loadImagesIfNeeded(PetAlbumState albumState, PetAlbumNotifier notifier) {
    if (temporaryImage != null &&
        !albumState.isLoading &&
        albumState.images.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.loadImages(showLoading: false);
      });
    }
  }

  void checkEntryMessage(List<PetImage> images) {
    if (_hasCheckedEntry) return;
    if (images.isEmpty || currentUserId.isEmpty) return;

    final newestImage = images.first;
    final isFromPartner =
        newestImage.userId != currentUserId && newestImage.userId == partnerId;
    final isRecent =
        DateTime.now().difference(newestImage.actionAt).inHours < 24;

    if (isFromPartner && isRecent) {
      _hasCheckedEntry = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showEntryMessage = true;
        entryMessageText = '❤️ Người kia vừa thêm ảnh';
        entryMessageController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 2500), () {
            showEntryMessage = false;
            entryMessageController.reset();
            onStateChanged();
          });
        });
        onStateChanged();
      });
    }
  }

  void handleVerticalDragStart() {
    _isDraggingVertically = false;
    verticalDragOffset = 0.0;
    onStateChanged();
  }

  void handleVerticalDragUpdate(double deltaY) {
    verticalDragOffset += deltaY;
    if (!_isDraggingVertically && verticalDragOffset.abs() > 20) {
      _isDraggingVertically = true;
    }
    onStateChanged();
  }

  bool handleVerticalDragEnd(
    bool canPop,
    VoidCallback onPop,
    VoidCallback onGoHome,
  ) {
    if (!_isDraggingVertically || verticalDragOffset.abs() <= 100) {
      verticalDragOffset = 0.0;
      onStateChanged();
      return false;
    }
    if (canPop) {
      onPop();
    } else {
      onGoHome();
    }
    return true;
  }

  void handleReaction(String emoji, Offset position, List<PetImage> images) {
    if (realIndex < 0 || realIndex >= images.length) return;

    final image = images[realIndex];
    final imageId = image.id;
    if (imageId.isEmpty) return;

    // 1. Hiệu ứng UI tức thì (Không chờ API)
    HapticFeedback.lightImpact();
    reactionParticleController.emit(emoji, position: position);

    // 2. Logic gom nhóm (Debounce) gửi API
    final key = "${imageId}_$emoji";
    _reactionPendingCounts[key] = (_reactionPendingCounts[key] ?? 0) + 1;

    _reactionDebounceTimers[key]?.cancel();
    _reactionDebounceTimers[key] = Timer(
      const Duration(milliseconds: 1000),
      () async {
        final count = _reactionPendingCounts[key] ?? 0;
        _reactionPendingCounts.remove(key);
        _reactionDebounceTimers.remove(key);

        if (count > 0) {
          final repository = ref.read(petImageRepositoryProvider);
          await repository.sendReaction(
            imageId: imageId,
            emoji: emoji,
            count: count,
          );
        }
      },
    );

    // 3. Cập nhật UI ngay lập tức cho chính entity ảnh (Local update)
    final updatedGroups = List<PetReactionGroup>.from(image.reactionGroups);
    final groupIdx = updatedGroups.indexWhere((g) => g.emoji == emoji);
    if (groupIdx != -1) {
      updatedGroups[groupIdx] = PetReactionGroup(
        emoji: emoji,
        count: updatedGroups[groupIdx].count + 1,
      );
    } else {
      updatedGroups.add(PetReactionGroup(emoji: emoji, count: 1));
    }

    images[realIndex] = image.copyWith(
      reactionTotalCount: image.reactionTotalCount + 1,
      reactionGroups: updatedGroups,
    );
    onStateChanged();
  }

  void handleTap() {
    _tapCount++;
    if (_tapCount == 1) {
      _tapTimer = Timer(const Duration(milliseconds: 220), () {
        if (_tapCount == 1) {
          nextByTap();
        }
        _tapCount = 0;
      });
    } else if (_tapCount >= 2) {
      _tapTimer?.cancel();
      _tapCount = 0;
      handleDoubleTap();
    }
  }

  void handleDoubleTap() {
    HapticFeedback.mediumImpact();
  }

  void nextByTap() {
    swiperController.swipe(card_swiper.CardSwiperDirection.left);
  }

  void prevByTap() {
    if (!canPrev()) return;
    if (isUndoing) return;
    debugPrint(
      '[UNDO] prevByTap: realIndex=$realIndex, canPrev=${canPrev()}, isUndoing=$isUndoing',
    );
    HapticFeedback.mediumImpact();
    isUndoing = true;
    onStateChanged();
    swiperController.undo();
    debugPrint('[UNDO] prevByTap: swiperController.undo() called');
  }

  void handleLongPressStart(PetImage image) {
    isHolding = true;
    HapticFeedback.heavyImpact();
    onStateChanged();
  }

  void handleLongPressEnd() {
    isHolding = false;
    onStateChanged();
  }

  bool isUndoing = false;
  int realIndex = 0;

  void syncIndex(int index) {
    if (realIndex != index) {
      realIndex = index;
      onStateChanged();
    }
  }

  bool canNext(int totalCards) => realIndex < totalCards - 1;

  bool canPrev() => realIndex > 0;

  void next(
    int totalCards,
    bool hasTemporaryImage,
    List<PetImage> filteredImages,
    PetAlbumState albumState,
    PetAlbumNotifier albumNotifier,
  ) {
    swipeCount++;
    final imageIndex = hasTemporaryImage ? realIndex - 1 : realIndex;

    if (imageIndex >= 0 && imageIndex < filteredImages.length) {
      checkPetStateChange(filteredImages);

      if (imageIndex >= filteredImages.length - 10 &&
          filteredImages.length > 10) {
        checkMemoryHighlight(filteredImages, imageIndex);
      }

      if (imageIndex >= filteredImages.length - 1 &&
          filteredImages.isNotEmpty) {
        showSessionEnding();
      }

      if (realIndex >= totalCards - 3 &&
          albumState.hasMore &&
          !albumState.isLoadingMore) {
        albumNotifier.loadMore();
      }
    }
  }

  void prev() {}

  void reset() {
    realIndex = 0;
    Future.microtask(() {
      swiperController.moveTo(0);
    });
  }

  void checkPetStateChange(List<PetImage> images) {
    if (images.isEmpty) return;

    final now = DateTime.now();
    final recentImages = images.where((img) {
      return now.difference(img.actionAt).inHours < 24;
    }).length;

    if (recentImages >= 5 && swipeCount % 5 == 0) {
      showPartnerSignal = true;
      partnerSignalText = '🐣 Pet lớn hơn khi cả hai cùng dùng app';
      onStateChanged();

      partnerSignalController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          showPartnerSignal = false;
          partnerSignalController.reset();
          onStateChanged();
        });
      });
    }
  }

  void checkMemoryHighlight(List<PetImage> images, int reversedIndex) {
    if (reversedIndex < 0 || reversedIndex >= images.length) return;
    if (swipeCount - _lastMemorySwipeCount < 5) return;

    final image = images[reversedIndex];
    final daysDiff = DateTime.now().difference(image.actionAt).inDays;

    if (daysDiff >= 7) {
      _lastMemorySwipeCount = swipeCount;

      if (daysDiff < 30) {
        memoryText = '📅 ${daysDiff ~/ 7} tuần trước – lần đầu chụp ảnh này';
      } else if (daysDiff < 90) {
        memoryText = '💭 ${daysDiff ~/ 30} tháng trước – kỷ niệm đẹp';
      } else {
        memoryText = '📚 Kỷ niệm cũ – nhớ lại ngày đó';
      }

      showMemoryHighlight = true;
      onStateChanged();

      memoryHighlightController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          showMemoryHighlight = false;
          memoryHighlightController.reset();
          onStateChanged();
        });
      });
    }
  }

  void showSessionEnding() {
    if (swipeCount > 0 && swipeCount % 50 != 0) return;
    onSessionEnding?.call();
  }

  PetImage? findUploadedImage(List<PetImage> images) {
    if (temporaryImage == null || images.isEmpty) return null;

    try {
      final found = images.firstWhere((image) {
        final timeDiff = image.actionAt
            .difference(temporaryImage!.capturedAt)
            .abs()
            .inSeconds;
        final sameUser = image.userId == currentUserId;
        final sameCaption =
            (image.text == null && temporaryImage!.caption == null) ||
            (image.text == temporaryImage!.caption);
        // Nới lỏng so sánh thời gian lên 60 giây vì upload API/Bắt mạng chậm có thể làm lệch actionAt
        return sameUser && sameCaption && timeDiff < 60;
      });

      // Nếu đã tìm thấy ảnh từ Server khớp với ảnh Temporary, lập tức xoá luôn Temporary cache đi
      // Tránh việc UI bị render 2 card trùng lặp nhau hoặc card trắng.
      if (found.imageUrl.isNotEmpty && temporaryImage != null) {
        debugPrint(
          '[TEMP] Found uploaded image, clearing temporaryImage and resetting to index 0',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          temporaryImage = null;
          realIndex = 0;
          swiperController.moveTo(0);
          onStateChanged();
        });
      }
      return found;
    } catch (_) {
      return null;
    }
  }

  List<PetImage> getFilteredImages(
    List<PetImage> images,
    bool shouldShowTemporaryImage,
    PetImage? uploadedImage,
  ) {
    return (shouldShowTemporaryImage && uploadedImage != null)
        ? images.where((img) => img.imageUrl != uploadedImage.imageUrl).toList()
        : images;
  }

  IconData getMemoryIcon(DateTime dateTime) {
    final daysDiff = DateTime.now().difference(dateTime).inDays;
    if (daysDiff == 0) {
      return Icons.today;
    } else if (daysDiff == 1) {
      return Icons.history;
    } else if (daysDiff < 7) {
      return Icons.access_time;
    } else {
      return Icons.calendar_today;
    }
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  double getCardHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth;
    return cardWidth * 4 / 3.9;
  }

  double getCardWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}
