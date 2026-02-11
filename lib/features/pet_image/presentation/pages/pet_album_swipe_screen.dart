import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/presentation/controllers/pet_album_swipe_controller.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_album_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_album_header.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/swipe/swipe_widgets.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart' as card_swiper;

class PetAlbumSwipeScreen extends ConsumerStatefulWidget {
  const PetAlbumSwipeScreen({super.key});

  @override
  ConsumerState<PetAlbumSwipeScreen> createState() =>
      _PetAlbumSwipeScreenState();
}

class _PetAlbumSwipeScreenState extends ConsumerState<PetAlbumSwipeScreen>
    with TickerProviderStateMixin {
  late PetAlbumSwipeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PetAlbumSwipeController(
      vsync: this,
      ref: ref,
      contextGetter: () => context,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final albumState = ref.watch(petAlbumNotifierProvider);
    final albumNotifier = ref.read(petAlbumNotifierProvider.notifier);
    final tempCaptured = ref.watch(temporaryCapturedImageProvider);

    // Sync temp image to controller immediately
    if (_controller.temporaryImage != tempCaptured) {
      _controller.temporaryImage = tempCaptured;
    }

    final images = _controller.getSortedImages(albumState);

    ref.listen<TemporaryCapturedImage?>(temporaryCapturedImageProvider, (
      previous,
      next,
    ) {
      _controller.updateTemporaryImage(next);
    });

    _controller.loadImagesIfNeeded(albumState, albumNotifier);
    _controller.checkEntryMessage(images);

    final canPop = context.canPop();

    final captureState = ref.watch(petCaptureNotifierProvider);

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.mounted) {
                context.go(AppRoutes.home);
              }
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LoveBackground(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: SafeArea(
              child: GestureDetector(
                onVerticalDragStart: (_) =>
                    _controller.handleVerticalDragStart(),
                onVerticalDragUpdate: (details) =>
                    _controller.handleVerticalDragUpdate(details.delta.dy),
                onVerticalDragEnd: (details) =>
                    _controller.handleVerticalDragEnd(
                      canPop,
                      () => context.pop(),
                      () => context.go(AppRoutes.home),
                    ),
                onTap: _controller.nextByTap, // Chạm 1 lần là qua liền
                onDoubleTap:
                    _controller.handleDoubleTap, // Chạm 2 lần là thả tim
                child: Transform.translate(
                  offset: Offset(0, _controller.verticalDragOffset * 0.3),
                  child: Opacity(
                    opacity:
                        1.0 -
                        (_controller.verticalDragOffset.abs() / 300).clamp(
                          0.0,
                          0.5,
                        ),
                    child: FadeTransition(
                      opacity: _controller.fadeController,
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              PetAlbumHeader(canPop: canPop),
                              Expanded(
                                child: _buildSwipeContent(
                                  albumState,
                                  albumNotifier,
                                  images,
                                  captureState,
                                ),
                              ),
                            ],
                          ),
                          if (_controller.showEntryMessage &&
                              _controller.entryMessageText != null)
                            SwipeEntryMessageOverlay(
                              animation: _controller.entryMessageController,
                              text: _controller.entryMessageText,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeContent(
    PetAlbumState albumState,
    PetAlbumNotifier albumNotifier,
    List<PetImage> images,
    PetCaptureState captureState,
  ) {
    final cardWidth = _controller.getCardWidth(context);
    final cardHeight = _controller.getCardHeight(context);

    if (_controller.temporaryImage == null &&
        albumState.isLoading &&
        images.isEmpty) {
      return SwipeSkeletonCard(
        cardWidth: cardWidth,
        cardHeight: cardHeight,
        shimmerAnimation: _controller.shimmerController,
      );
    }

    if (albumState.isEmpty && _controller.temporaryImage == null) {
      return const SwipeEmptyState();
    }

    if (albumState.errorMessage != null && images.isEmpty) {
      return SwipeErrorState(
        errorMessage: albumState.errorMessage!,
        onRetry: () => albumNotifier.loadImages(),
      );
    }

    final hasTemporaryImage = _controller.temporaryImage != null;
    final uploadedImage = _controller.findUploadedImage(images);
    final shouldShowTemporaryImage = hasTemporaryImage;
    final filteredImages = _controller.getFilteredImages(
      images,
      shouldShowTemporaryImage,
      uploadedImage,
    );

    if (!shouldShowTemporaryImage && filteredImages.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalCards =
        filteredImages.length + (shouldShowTemporaryImage ? 1 : 0);

    return Stack(
      children: [
        card_swiper.CardSwiper(
          key: ValueKey("swiper_${totalCards}_${shouldShowTemporaryImage}"),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          controller: _controller.swiperController,

          cardsCount: totalCards,
          numberOfCardsDisplayed: totalCards < 2 ? totalCards : 2,
          isLoop: false,

          // ⭐ BẬT UNDO STACK CỦA LIB: TRUE + Config Hướng
          showBackCardOnUndo: true,
          undoDirection: card_swiper.UndoDirection.right,

          allowedSwipeDirection: card_swiper.AllowedSwipeDirection.only(
            left: _controller.canNext(totalCards),
            right: _controller.canPrev(),
          ),

          onUndo: (previousIndex, currentIndex, direction) {
            debugPrint(
              "SWIPE UNDO (Back) - Syncing state destId:$currentIndex",
            );
            _controller.prev();
            return true;
          },

          onSwipe: (previousIndex, currentIndex, direction) {
            debugPrint("onSwipe detected: $direction");

            /// NEXT
            if (direction == card_swiper.CardSwiperDirection.left) {
              _controller.syncIndex(currentIndex ?? 0);
              _controller.next(
                totalCards,
                hasTemporaryImage,
                filteredImages,
                albumState,
                albumNotifier,
              );
              return true;
            }

            /// PREVIOUS / UNDO
            if (direction == card_swiper.CardSwiperDirection.right) {
              _controller.syncIndex(currentIndex ?? 0);
              debugPrint("SWIPE RIGHT (Undo) -> Triggering Load Previous");
              _controller.swiperController.undo();
              return false; // Prevent "Swipe Away", trigger Undo instead
            }

            return false;
          },

          threshold: 40,
          maxAngle: 20,
          backCardOffset: Offset.zero,
          scale: 0.95,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            try {
              // STEP 4 - dùng index từ lib
              final real = index;

              if (real < 0 || real >= totalCards) {
                return const SizedBox.shrink();
              }

              if (shouldShowTemporaryImage && real == 0) {
                final temp = _controller.temporaryImage!;
                final uploadedImage = _controller.findUploadedImage(images);

                return SwipeImageCard(
                  image: uploadedImage,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                  isNextCard: percentThresholdX != 0,
                  isFromPartner: false,
                  isLastImage: images.length == 1 && !albumState.hasMore,
                  showMemoryHighlight: false,
                  shimmerAnimation: _controller.shimmerController,
                  memoryIcon: (uploadedImage != null)
                      ? _controller.getMemoryIcon(uploadedImage.actionAt)
                      : Icons.today,
                  formattedDate: (uploadedImage != null)
                      ? _controller.formatDateTime(uploadedImage.actionAt)
                      : 'Hôm nay',
                  onLongPressStart: () {},
                  onLongPressEnd: () {},
                  localImageBytes: temp.bytes,
                  localRotation: temp.sensorRotation,
                  localPosition: temp.sensorPosition,
                  isUploading:
                      (uploadedImage == null) && captureState.isSending,
                  localCaption: temp.caption,
                );
              }

              final imageIndex = shouldShowTemporaryImage ? real - 1 : real;

              if (imageIndex < 0) {
                return const SizedBox.shrink();
              }

              if (imageIndex >= filteredImages.length) {
                return SwipeGhostCard(
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                  isLoading: albumState.isLoadingMore,
                );
              }

              final image = filteredImages[imageIndex];
              final isNextCard = percentThresholdX != 0;

              final isLastImage =
                  imageIndex == filteredImages.length - 1 &&
                  !albumState.hasMore;
              final isFromPartner =
                  image.userId != _controller.currentUserId &&
                  image.userId == _controller.partnerId;

              return SwipeImageCard(
                image: image,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                isNextCard: isNextCard,
                isFromPartner: isFromPartner,
                isLastImage: isLastImage,
                showMemoryHighlight: _controller.showMemoryHighlight,
                shimmerAnimation: _controller.shimmerController,
                memoryIcon: _controller.getMemoryIcon(image.actionAt),
                formattedDate: _controller.formatDateTime(image.actionAt),
                onLongPressStart: () => _controller.handleLongPressStart(image),
                onLongPressEnd: () => _controller.handleLongPressEnd(),
              );
            } catch (e) {
              debugPrint('⚠️ CardBuilder error at index $index: $e');
              return const SizedBox.shrink();
            }
          },
        ),
        if (_controller.showPartnerSignal &&
            _controller.partnerSignalText != null)
          SwipePartnerSignalOverlay(
            animation: _controller.partnerSignalController,
            text: _controller.partnerSignalText,
          ),
        if (_controller.showMemoryHighlight && _controller.memoryText != null)
          SwipeMemoryHighlightOverlay(
            animation: _controller.memoryHighlightController,
            text: _controller.memoryText,
          ),
        Positioned(
          bottom: 158,
          left: 0,
          right: 0,
          child: SwipeReactionBar(onReaction: _controller.handleReaction),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: SwipeCameraButton(
            onTap: () => context.push(AppRoutes.petCapture),
          ),
        ),
      ],
    );
  }
}
