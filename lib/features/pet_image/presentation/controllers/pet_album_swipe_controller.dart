import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_album_notifier.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart' as card_swiper;
import 'package:intl/intl.dart';

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
  final Random random = Random();

  double verticalDragOffset = 0.0;

  int swipeCount = 0;
  bool showPartnerSignal = false;
  String? partnerSignalText;
  bool isHolding = false;
  bool showMemoryHighlight = false;
  String? memoryText;
  bool showEntryMessage = false;
  String? entryMessageText;

  late AnimationController partnerSignalController;
  late AnimationController memoryHighlightController;
  late AnimationController shimmerController;
  late AnimationController entryMessageController;
  late AnimationController fadeController;

  TemporaryCapturedImage? temporaryImage;

  DateTime? _lastTapTime;
  int _tapCount = 0;

  void init() {
    partnerSignalController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800),
    );
    memoryHighlightController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600),
    );
    shimmerController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    entryMessageController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600),
    );
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
    swiperController.dispose();
    partnerSignalController.dispose();
    memoryHighlightController.dispose();
    shimmerController.dispose();
    entryMessageController.dispose();
    fadeController.dispose();
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
    return List<PetImage>.from(albumState.images)
      ..sort((a, b) => b.actionAt.compareTo(a.actionAt));
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
    if (images.isNotEmpty && !showEntryMessage && currentUserId.isNotEmpty) {
      final newestImage = images.first;
      final isFromPartner =
          newestImage.userId != currentUserId &&
          newestImage.userId == partnerId;
      final isRecent =
          DateTime.now().difference(newestImage.actionAt).inHours < 24;

      if (isFromPartner && isRecent) {
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
  }

  void handleVerticalDragStart() {
    verticalDragOffset = 0.0;
    onStateChanged();
  }

  void handleVerticalDragUpdate(double deltaY) {
    verticalDragOffset += deltaY;
    onStateChanged();
  }

  bool handleVerticalDragEnd(
    bool canPop,
    VoidCallback onPop,
    VoidCallback onGoHome,
  ) {
    if (verticalDragOffset.abs() > 100) {
      if (canPop) {
        onPop();
      } else {
        onGoHome();
      }
      return true;
    } else {
      verticalDragOffset = 0.0;
      onStateChanged();
      return false;
    }
  }

  void handleReaction(String emoji) {
    HapticFeedback.lightImpact();
  }

  void handleDoubleTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!).inMilliseconds < 300) {
      _tapCount++;
      if (_tapCount == 2) {
        _showLikeAnimation();
        _tapCount = 0;
      }
    } else {
      _tapCount = 1;
    }
    _lastTapTime = now;
  }

  void _showLikeAnimation() {}

  void handleLongPressStart(PetImage image) {
    isHolding = true;
    onStateChanged();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isHolding) {
        _showMoodDialog(image);
      }
    });
  }

  void handleLongPressEnd() {
    isHolding = false;
    onStateChanged();
  }

  void _showMoodDialog(PetImage image) {}

  int realIndex = 0;

  bool canNext(int totalCards) => realIndex < totalCards - 1;

  bool canPrev() => realIndex > 0;

  void next(
    int totalCards,
    bool hasTemporaryImage,
    List<PetImage> filteredImages,
    PetAlbumState albumState,
    PetAlbumNotifier albumNotifier,
  ) {
    if (canNext(totalCards)) {
      realIndex++;
      onStateChanged();
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
  }

  void prev() {
    if (canPrev()) {
      realIndex--;
      onStateChanged();
    }
  }

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

    final image = images[reversedIndex];
    final daysDiff = DateTime.now().difference(image.actionAt).inDays;

    if (daysDiff >= 7 && random.nextDouble() < 0.15) {
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

    final context = contextGetter();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😴', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Kỷ niệm cũ rồi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pet nằm ngủ trong ký ức 💭',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Quay lại hiện tại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PetImage? findUploadedImage(List<PetImage> images) {
    if (temporaryImage == null || images.isEmpty) return null;

    try {
      return images.firstWhere((image) {
        final timeDiff = image.actionAt
            .difference(temporaryImage!.capturedAt)
            .abs()
            .inSeconds;
        final sameUser = image.userId == currentUserId;
        final sameCaption =
            (image.text == null && temporaryImage!.caption == null) ||
            (image.text == temporaryImage!.caption);
        return sameUser && sameCaption && timeDiff < 5;
      });
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

  int calculateTotalCards(
    bool shouldShowTemporaryImage,
    List<PetImage> filteredImages,
    bool hasMore,
  ) {
    return (shouldShowTemporaryImage ? 1 : 0) +
        filteredImages.length +
        (hasMore ? 2 : 0);
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
