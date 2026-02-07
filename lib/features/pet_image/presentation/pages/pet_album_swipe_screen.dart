import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_album_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_album_header.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart' as card_swiper;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class PetAlbumSwipeScreen extends ConsumerStatefulWidget {
  const PetAlbumSwipeScreen({super.key});

  @override
  ConsumerState<PetAlbumSwipeScreen> createState() =>
      _PetAlbumSwipeScreenState();
}

class _PetAlbumSwipeScreenState extends ConsumerState<PetAlbumSwipeScreen>
    with TickerProviderStateMixin {
  final card_swiper.CardSwiperController _swiperController =
      card_swiper.CardSwiperController();
  final Random _random = Random();

  // State tracking
  double _verticalDragOffset = 0.0;
  // 🔥 _currentIndex: index trong images[] (không phải swiper index)
  // Luôn là imageIndex, có thể dùng cho tracking/debug trong tương lai
  // ignore: unused_field
  int _currentIndex = 0;
  int _swipeCount = 0;
  bool _showPartnerSignal = false;
  String? _partnerSignalText;
  bool _isHolding = false;
  bool _showMemoryHighlight = false;
  String? _memoryText;
  bool _showEntryMessage = false;
  String? _entryMessageText;

  // Animation controllers
  late AnimationController _partnerSignalController;
  late AnimationController _memoryHighlightController;
  late AnimationController _shimmerController;
  late AnimationController _entryMessageController;
  late AnimationController _fadeController;

  // 🔥 Track temporary image
  TemporaryCapturedImage? _temporaryImage;

  @override
  void initState() {
    super.initState();
    _partnerSignalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _memoryHighlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _entryMessageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 🔥 FIX 1: Mặc định HIỂN THỊ ngay từ frame đầu (không opacity = 0)
    // Fade chỉ dùng cho route transition, không cho frame đầu
    _fadeController.value = 1.0;

    // 🔥 Lấy temporary image từ provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tempImage = ref.read(temporaryCapturedImageProvider);
      if (tempImage != null && mounted) {
        setState(() {
          _temporaryImage = tempImage;
        });
        // ❌ KHÔNG gọi _fadeController.forward() nữa
        // Fade chỉ dùng cho route transition
      }
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _partnerSignalController.dispose();
    _memoryHighlightController.dispose();
    _shimmerController.dispose();
    _entryMessageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final albumState = ref.watch(petAlbumNotifierProvider);
    final albumNotifier = ref.read(petAlbumNotifierProvider.notifier);
    // Đảm bảo ảnh mới nhất ở đầu: sắp xếp theo actionAt giảm dần
    final images = List<PetImage>.from(albumState.images)
      ..sort((a, b) => b.actionAt.compareTo(a.actionAt));
    final storageService = ref.read(storageServiceProvider);
    final currentUser = storageService.getUser();
    final currentUserId = currentUser?.id ?? '';
    final partnerId = currentUser?.partnerId;

    // 🔥 Listen temporary image provider để cập nhật UI khi upload xong
    ref.listen<TemporaryCapturedImage?>(temporaryCapturedImageProvider, (
      previous,
      next,
    ) {
      if (mounted) {
        setState(() {
          _temporaryImage = next;
        });
      }
    });

    // 🔥 Load ảnh ngầm nếu chưa load (chỉ khi có temporary image)
    if (_temporaryImage != null && !albumState.isLoading && images.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        albumNotifier.loadImages(showLoading: false);
      });
    }

    // 1️⃣ ENTRY MOMENT: Check nếu ảnh mới nhất là của partner
    if (images.isNotEmpty && !_showEntryMessage && currentUserId.isNotEmpty) {
      // images đã được sắp xếp mới nhất trước, nên first = mới nhất
      final newestImage = images.first;
      final isFromPartner =
          newestImage.userId != currentUserId &&
          newestImage.userId == partnerId;
      final isRecent =
          DateTime.now().difference(newestImage.actionAt).inHours < 24;

      if (isFromPartner && isRecent) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showEntryMessage = true;
          _entryMessageText = '❤️ Người kia vừa thêm ảnh';
          _entryMessageController.forward().then((_) {
            Future.delayed(const Duration(milliseconds: 2500), () {
              if (mounted) {
                setState(() {
                  _showEntryMessage = false;
                });
                _entryMessageController.reset();
              }
            });
          });
        });
      }
    }

    final canPop = context.canPop();

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop && !canPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.home);
            }
          });
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
                onVerticalDragStart: (_) {
                  setState(() {
                    _verticalDragOffset = 0.0;
                  });
                },
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _verticalDragOffset += details.delta.dy;
                  });
                },
                onVerticalDragEnd: (details) {
                  if (_verticalDragOffset.abs() > 100) {
                    if (canPop) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  } else {
                    setState(() {
                      _verticalDragOffset = 0.0;
                    });
                  }
                },
                onTapDown: (_) => _handleDoubleTap(),
                child: Transform.translate(
                  offset: Offset(0, _verticalDragOffset * 0.3),
                  child: Opacity(
                    opacity:
                        1.0 - (_verticalDragOffset.abs() / 300).clamp(0.0, 0.5),
                    child: FadeTransition(
                      opacity: _fadeController,
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              PetAlbumHeader(canPop: canPop),
                              Expanded(
                                child: _buildSwipeContent(
                                  albumState,
                                  images,
                                  albumNotifier,
                                  currentUserId,
                                  partnerId,
                                ),
                              ),
                            ],
                          ),
                          // 1️⃣ ENTRY MOMENT: Partner signal
                          if (_showEntryMessage && _entryMessageText != null)
                            _buildEntryMessage(),
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
    List<PetImage> images,
    PetAlbumNotifier albumNotifier,
    String currentUserId,
    String? partnerId,
  ) {
    // 🔥 FIX 2: Skeleton KHÔNG được hiển thị nếu có temporary image
    // Khi đã có ảnh vừa chụp → tuyệt đối không skeleton
    if (_temporaryImage == null && albumState.isLoading && images.isEmpty) {
      return _buildSkeletonCards();
    }

    if (albumState.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có ảnh nào',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (albumState.errorMessage != null && images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.errorIcon),
            const SizedBox(height: 16),
            Text(
              albumState.errorMessage!,
              style: TextStyle(fontSize: 16, color: AppColors.errorText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => albumNotifier.loadImages(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // 🔥 Temporary image LUÔN hiển thị ở vị trí đầu tiên (ảnh vừa chụp)
    // Dù API đã load xong, vẫn hiển thị temporary image, chỉ cập nhật EXP từ server
    // 🔥 QUAN TRỌNG: Đọc lại từ provider mỗi lần build để đảm bảo luôn có giá trị mới nhất
    final tempImageFromProvider = ref.read(temporaryCapturedImageProvider);
    if (tempImageFromProvider != null &&
        _temporaryImage != tempImageFromProvider) {
      // Cập nhật nếu provider có giá trị mới
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _temporaryImage = tempImageFromProvider;
          });
        }
      });
    }
    final hasTemporaryImage = _temporaryImage != null;

    // 🔥 Tìm ảnh match từ API để lấy EXP và thông tin (nhưng không thay thế ảnh)
    PetImage? uploadedImage;
    if (hasTemporaryImage && images.isNotEmpty) {
      try {
        uploadedImage = images.firstWhere((image) {
          if (_temporaryImage == null) return false;
          final timeDiff = image.actionAt
              .difference(_temporaryImage!.capturedAt)
              .abs()
              .inSeconds;
          final sameUser =
              image.userId == ref.read(storageServiceProvider).getUser()?.id;
          final sameCaption =
              (image.text == null && _temporaryImage!.caption == null) ||
              (image.text == _temporaryImage!.caption);
          return sameUser && sameCaption && timeDiff < 5;
        });
      } catch (_) {
        // Không tìm thấy match
        uploadedImage = null;
      }
    }

    // 🔥 Temporary image LUÔN hiển thị khi có (không clear)
    final shouldShowTemporaryImage = hasTemporaryImage;

    // 🔥 FIX 3: Ép CardSwiper có content ngay frame đầu
    // Nếu có temporary image hoặc images → luôn có ít nhất 1 card
    if (!shouldShowTemporaryImage && images.isEmpty) {
      return const SizedBox.shrink();
    }

    // 🔥 Tính totalCards: temporary image (luôn 1 nếu có) + images từ API + ghost cards
    // QUAN TRỌNG: Temporary image LUÔN ở index 0, không bao giờ bị thay thế
    // 🔥 FIX: Nếu có uploadedImage match → loại bỏ khỏi images để tránh duplicate
    final filteredImages = (shouldShowTemporaryImage && uploadedImage != null)
        ? images
              .where((img) => img.imageUrl != uploadedImage!.imageUrl)
              .toList()
        : images;
    final totalCards =
        (shouldShowTemporaryImage ? 1 : 0) +
        filteredImages.length +
        (albumState.hasMore ? 2 : 0);

    // 🔥 Debug: Đảm bảo temporary image luôn hiển thị
    if (shouldShowTemporaryImage && totalCards == 0) {
      debugPrint(
        '⚠️ WARNING: shouldShowTemporaryImage=true nhưng totalCards=0',
      );
    }

    return Stack(
      children: [
        card_swiper.CardSwiper(
          // 🔥 Không dùng key để tránh reset CardSwiper
          padding: EdgeInsetsGeometry.symmetric(horizontal: 8, vertical: 14),
          controller: _swiperController,
          cardsCount: totalCards,
          onSwipe: (previousIndex, currentIndex, direction) {
            // 🔥 Validate previousIndex
            if (previousIndex < 0 || previousIndex >= totalCards) {
              return true;
            }

            // 🔥 Chặn swipe trái ở card cuối cùng (khi không còn ảnh để load)
            final lastRealCardIndex =
                (shouldShowTemporaryImage ? 1 : 0) + filteredImages.length - 1;

            if (previousIndex >= lastRealCardIndex &&
                direction == card_swiper.CardSwiperDirection.left &&
                !albumState.hasMore) {
              return false; // đã "chạm đáy ký ức", không cho swipe tiếp
            }

            // Tính imageIndex từ previousIndex
            final imageIndex = hasTemporaryImage
                ? previousIndex - 1
                : previousIndex;

            // Cập nhật _currentIndex và các logic khác khi imageIndex hợp lệ
            if (imageIndex >= 0 && imageIndex < filteredImages.length) {
              setState(() {
                _currentIndex = imageIndex;
              });
              _swipeCount++;

              // 3️⃣ VARIABLE REWARD: Pet state change
              _checkPetStateChange(filteredImages, currentUserId, partnerId);

              // 2️⃣ Memory highlight chỉ khi swipe sâu (ảnh cũ)
              if (imageIndex >= filteredImages.length - 10 &&
                  filteredImages.length > 10) {
                _checkMemoryHighlight(filteredImages, imageIndex);
              }

              // 7️⃣ SESSION ENDING: Khi đến ảnh cũ nhất
              if (imageIndex >= filteredImages.length - 1 &&
                  filteredImages.isNotEmpty) {
                _showSessionEnding();
              }

              // 🔥 Load more khi gần cuối
              final lastImageSwiperIndex =
                  (hasTemporaryImage ? 1 : 0) + filteredImages.length - 1;
              final isNearEnd = previousIndex >= lastImageSwiperIndex - 2;

              if (isNearEnd &&
                  albumState.hasMore &&
                  !albumState.isLoadingMore) {
                albumNotifier.loadMore();
              }
            }
            return true;
          },
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            // 🔥 FIX: Validate index trước khi tính toán (tránh index âm)
            // Thêm try-catch để tránh crash khi CardSwiper gọi với index không hợp lệ
            try {
              if (index < 0 || index >= totalCards) {
                return const SizedBox.shrink();
              }

              // 🔥 Card đầu tiên = temporary image (LUÔN hiển thị khi có)
              if (shouldShowTemporaryImage && index == 0) {
                return _buildTemporaryImageCard(
                  images: images,
                  uploadedImage: uploadedImage,
                );
              }

              // 🔥 Ghost cards (cuối danh sách)
              final imageIndex = shouldShowTemporaryImage ? index - 1 : index;

              // Validate imageIndex trước khi truy cập images
              if (imageIndex < 0) {
                return const SizedBox.shrink();
              }

              if (imageIndex >= filteredImages.length) {
                return _buildGhostCard(albumState.isLoadingMore);
              }

              // images đã được sắp xếp mới nhất trước
              // imageIndex 0 = ảnh mới nhất, imageIndex cuối = ảnh cũ nhất
              final image = filteredImages[imageIndex];

              // 🔥 BƯỚC 3: Blur dựa vào swiper index, không phụ thuộc _currentIndex
              // Card index 0 = temporary/current, index 1 = current (nếu không temp), index 2 = preview (blur)
              final isNextCard = index == (hasTemporaryImage ? 2 : 1);

              // 🔥 Kiểm tra có phải ảnh cuối không (để hiển thị badge "Hết ảnh")
              final isLastImage =
                  imageIndex == filteredImages.length - 1 &&
                  !albumState.hasMore;

              return _buildImageCard(
                image,
                isNextCard: isNextCard,
                currentUserId: currentUserId,
                partnerId: partnerId,
                isLastImage: isLastImage,
              );
            } catch (e) {
              // 🔥 FIX: Tránh crash khi có lỗi bất ngờ
              debugPrint('⚠️ CardBuilder error at index $index: $e');
              return const SizedBox.shrink();
            }
          },
          // 🔥 Chặn swipe right khi ở card đầu (không có gì để undo)
          // 🔥 CHỈ cho phép swipe left (xem ảnh cũ hơn)
          // Undo sẽ được xử lý bằng controller.undo() khi cần
          allowedSwipeDirection: card_swiper.AllowedSwipeDirection.only(
            left: true,
            right: false,
          ),
          threshold: 50,
          maxAngle: 30,
          isLoop: false,
          backCardOffset: const Offset(0, 0),
          scale: 0.9,
        ),
        // 3️⃣ PARTNER SIGNAL: Partner đã xem/thích
        if (_showPartnerSignal && _partnerSignalText != null)
          _buildPartnerSignalOverlay(),
        // 2️⃣ Memory highlight overlay
        if (_showMemoryHighlight && _memoryText != null)
          _buildMemoryHighlightOverlay(),
        // 🔥 Reaction bar
        Positioned(bottom: 158, left: 0, right: 0, child: _buildReactionBar()),
        Positioned(bottom: 24, right: 24, child: _buildCameraButton(context)),
      ],
    );
  }

  Widget _buildReactionBar() {
    final reactions = ['❤️', '😍', '😂', '😢'];

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.asMap().entries.map((entry) {
          final index = entry.key;
          final emoji = entry.value;
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 20),
            child: _ReactionButton(
              emoji: emoji,
              onTap: () => _handleReaction(emoji),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleReaction(String emoji) {
    HapticFeedback.lightImpact();
  }

  Widget _buildCameraButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.petCapture),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPink.withOpacity(0.9),
              const Color(0xFFE91E63).withOpacity(0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              alignment: Alignment.center,
              color: Colors.white.withOpacity(0.1),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 1️⃣ ENTRY MOMENT: Skeleton cards
  Widget _buildSkeletonCards() {
    final cardHeight = _getCardHeight();
    final cardWidth = _getCardWidth();

    return Center(
      child: Container(
        width: cardWidth,
        height: cardHeight,
        constraints: BoxConstraints(maxWidth: cardWidth, maxHeight: cardHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(44),
          color: Colors.white.withOpacity(0.1),
        ),
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _shimmerController.value * 2, 0),
                  end: Alignment(1.0 + _shimmerController.value * 2, 0),
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method để tính chiều cao card - style giống capture_layout_metrics
  double _getCardHeight() {
    final screenWidth = MediaQuery.of(context).size.width;
    // 🔥 Dùng 95% width như preview trong capture screen để khớp kích thước
    final cardWidth = screenWidth;
    // Tỷ lệ 4:3.9 giống capture layout
    return cardWidth * 4 / 3.9;
  }

  // Helper method để tính chiều rộng card - style giống capture_layout_metrics
  double _getCardWidth() {
    final screenWidth = MediaQuery.of(context).size.width;
    // 🔥 Dùng 95% width như preview trong capture screen để khớp kích thước
    return screenWidth;
  }

  // 5️⃣ INFINITE ILLUSION: Ghost card
  Widget _buildGhostCard(bool isLoading) {
    final cardHeight = _getCardHeight();
    final cardWidth = _getCardWidth();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      width: cardWidth,
      height: cardHeight,
      constraints: BoxConstraints(maxWidth: cardWidth, maxHeight: cardHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44),
        color: Colors.black.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '🕰️ Đang đào ký ức cũ hơn...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ] else ...[
              Icon(Icons.pets, size: 48, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                '🐾 Đang tìm thêm...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🔥 Build temporary image card (ảnh vừa chụp, local file)
  Widget _buildTemporaryImageCard({
    required List<PetImage> images,
    PetImage? uploadedImage,
  }) {
    if (_temporaryImage == null) {
      return const SizedBox.shrink();
    }

    final cardHeight = _getCardHeight();
    final cardWidth = _getCardWidth();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      width: cardWidth,
      height: cardHeight,
      constraints: BoxConstraints(maxWidth: cardWidth, maxHeight: cardHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(44),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🔥 Hiển thị ảnh từ bytes (local)
            Image.memory(
              _temporaryImage!.bytes,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text caption
                    if (_temporaryImage!.caption != null &&
                        _temporaryImage!.caption!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _temporaryImage!.caption!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    // Info row
                    Row(
                      children: [
                        // 🔥 EXP badge - luôn hiển thị 20 EXP
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '+20 EXP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Date
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.today,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateTime(_temporaryImage!.capturedAt),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(
    PetImage image, {
    bool isNextCard = false,
    required String currentUserId,
    String? partnerId,
    bool isLastImage = false,
  }) {
    final isFromPartner =
        image.userId != currentUserId && image.userId == partnerId;
    final cardHeight = _getCardHeight();
    final cardWidth = _getCardWidth();
    return GestureDetector(
      onLongPressStart: (_) {
        setState(() {
          _isHolding = true;
        });
        // 6️⃣ INVESTMENT: Hold để add mood
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isHolding && mounted) {
            _showMoodDialog(image);
          }
        });
      },
      onLongPressEnd: (_) {
        setState(() {
          _isHolding = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        width: cardWidth,
        height: cardHeight,
        constraints: BoxConstraints(maxWidth: cardWidth, maxHeight: cardHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(44),
          color: Colors
              .black, // 🔥 Background đen để không lộ khi ảnh không fill hết
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(44),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 4️⃣ ANTICIPATION: Blur next card
              CachedNetworkImage(
                imageUrl: image.imageUrl,
                fit: BoxFit
                    .cover, // 🔥 Dùng contain để hiển thị toàn bộ ảnh như preview camera
                color: isNextCard ? Colors.black.withOpacity(0.3) : null,
                colorBlendMode: isNextCard ? BlendMode.darken : null,
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit
                            .cover, // 🔥 Dùng contain để hiển thị toàn bộ ảnh như preview
                        alignment: Alignment.center, // Center alignment
                      ),
                    ),
                    child: isNextCard
                        ? BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              color: Colors.black.withOpacity(0.2),
                            ),
                          )
                        : null,
                  );
                },
                placeholder: (context, url) => _buildSkeletonPlaceholder(),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.backgroundLight,
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.errorIcon,
                      size: 48,
                    ),
                  ),
                ),
              ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text caption
                      if (image.text != null && image.text!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            image.text!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      // Partner signal (nếu là ảnh của partner)
                      if (isFromPartner)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryPink.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Từ người kia',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Info row
                      Row(
                        children: [
                          // EXP badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPink,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+${image.totalExp} EXP',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (image.hasBonus) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'BONUS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Date với memory highlight
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _showMemoryHighlight
                                  ? AppColors.primaryPink.withOpacity(0.8)
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getMemoryIcon(image.actionAt),
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDateTime(image.actionAt),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Mood (nếu có)
                      if (image.mood != null && image.mood!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.mood,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                image.mood!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // 🔥 Badge "Hết ảnh" khi là ảnh cuối
              if (isLastImage)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryPink.withOpacity(0.9),
                          AppColors.primaryPinkDark.withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Hết ảnh rồi!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonPlaceholder() {
    return Container(
      color: AppColors.backgroundLight,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerController.value * 2, 0),
                end: Alignment(1.0 + _shimmerController.value * 2, 0),
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 3️⃣ VARIABLE REWARD: Pet state change (không random, có ý nghĩa)
  void _checkPetStateChange(
    List<PetImage> images,
    String currentUserId,
    String? partnerId,
  ) {
    if (images.isEmpty) return;

    // Đếm số ảnh mới trong 24h
    final now = DateTime.now();
    final recentImages = images.where((img) {
      return now.difference(img.actionAt).inHours < 24;
    }).length;

    // Pet vui hơn khi có nhiều ảnh mới từ cả hai
    if (recentImages >= 5 && _swipeCount % 5 == 0) {
      setState(() {
        _showPartnerSignal = true;
        _partnerSignalText = '🐣 Pet lớn hơn khi cả hai cùng dùng app';
      });

      _partnerSignalController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            setState(() {
              _showPartnerSignal = false;
            });
            _partnerSignalController.reset();
          }
        });
      });
    }
  }

  Widget _buildPartnerSignalOverlay() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _partnerSignalController,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  _partnerSignalText ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1️⃣ ENTRY MOMENT: Entry message
  Widget _buildEntryMessage() {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _entryMessageController,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  _entryMessageText ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 2️⃣ Memory highlight - chỉ khi swipe sâu (ảnh cũ)
  void _checkMemoryHighlight(List<PetImage> images, int reversedIndex) {
    if (reversedIndex < 0 || reversedIndex >= images.length) return;

    final image = images[reversedIndex];
    final daysDiff = DateTime.now().difference(image.actionAt).inDays;

    // Chỉ hiển thị khi ảnh cũ (>= 7 ngày) và random nhẹ
    if (daysDiff >= 7 && _random.nextDouble() < 0.15) {
      if (daysDiff < 30) {
        _memoryText = '📅 ${daysDiff ~/ 7} tuần trước – lần đầu chụp ảnh này';
      } else if (daysDiff < 90) {
        _memoryText = '💭 ${daysDiff ~/ 30} tháng trước – kỷ niệm đẹp';
      } else {
        _memoryText = '📚 Kỷ niệm cũ – nhớ lại ngày đó';
      }

      setState(() {
        _showMemoryHighlight = true;
      });

      _memoryHighlightController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) {
            setState(() {
              _showMemoryHighlight = false;
            });
            _memoryHighlightController.reset();
          }
        });
      });
    }
  }

  Widget _buildMemoryHighlightOverlay() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _memoryHighlightController,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _memoryText ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMemoryIcon(DateTime dateTime) {
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

  // 6️⃣ INVESTMENT: Double tap to like
  DateTime? _lastTapTime;
  int _tapCount = 0;

  void _handleDoubleTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!).inMilliseconds < 300) {
      _tapCount++;
      if (_tapCount == 2) {
        // Double tap detected
        _showLikeAnimation();
        _tapCount = 0;
      }
    } else {
      _tapCount = 1;
    }
    _lastTapTime = now;
  }

  void _showLikeAnimation() {
    // Show heart animation
    // Implementation có thể thêm sau
  }

  // 6️⃣ INVESTMENT: Hold to add mood
  void _showMoodDialog(PetImage image) {
    // Show mood selection dialog
    // Implementation có thể thêm sau
  }

  // 7️⃣ SESSION ENDING - Kỷ niệm cũ rồi
  void _showSessionEnding() {
    // Chỉ hiển thị 1 lần
    if (_swipeCount > 0 && _swipeCount % 50 != 0) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
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
                onPressed: () => Navigator.of(context).pop(),
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

  String _formatDateTime(DateTime dateTime) {
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
}

class _ReactionButton extends StatefulWidget {
  final String emoji;
  final VoidCallback onTap;

  const _ReactionButton({required this.emoji, required this.onTap});

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(_isPressed ? 0.3 : 0.15),
                    Colors.white.withOpacity(_isPressed ? 0.2 : 0.08),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(widget.emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
          );
        },
      ),
    );
  }
}
