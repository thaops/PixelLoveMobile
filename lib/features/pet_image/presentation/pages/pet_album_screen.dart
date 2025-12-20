import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/presentation/models/timeline_item.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:pixel_love/features/pet_scene/providers/pet_scene_providers.dart';

class PetAlbumScreen extends ConsumerWidget {
  const PetAlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumState = ref.watch(petAlbumNotifierProvider);

    final canPop = context.canPop();

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop && !canPop) {
          // If cannot pop, navigate to home instead of exiting app
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
                    child: Row(
                      children: [
                        IconButton(
                          padding: const EdgeInsets.all(8),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                          ),
                          onPressed: () {
                            // Check if can pop, otherwise navigate to home
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.home);
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.primaryPinkDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: PetMiniStatusBar()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (albumState.isLoading && albumState.images.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        if (albumState.isEmpty) {
                          return _buildEmptyState();
                        }

                        final timelineItems = ref
                            .read(petAlbumNotifierProvider.notifier)
                            .buildTimelineItems();

                        return Container(
                          color: Colors.white.withOpacity(0.08),
                          child: RefreshIndicator(
                            onRefresh: () => ref
                                .read(petAlbumNotifierProvider.notifier)
                                .refresh(),
                            color: AppColors.primaryPink,
                            child: CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (index < timelineItems.length) {
                                          final item = timelineItems[index];
                                          final nextItem =
                                              index < timelineItems.length - 1
                                              ? timelineItems[index + 1]
                                              : null;
                                          return _buildTimelineItem(
                                            context,
                                            item,
                                            nextItem: nextItem,
                                          );
                                        } else if (albumState.hasMore) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                ref
                                                    .read(
                                                      petAlbumNotifierProvider
                                                          .notifier,
                                                    )
                                                    .loadMore();
                                              });
                                          return _buildLoadingMoreIndicator();
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                      childCount:
                                          timelineItems.length +
                                          (albumState.hasMore ? 1 : 0),
                                    ),
                                  ),
                                ),
                                if (albumState.isLoadingMore)
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build timeline item dựa trên type
  Widget _buildTimelineItem(
    BuildContext context,
    TimelineItem item, {
    TimelineItem? nextItem,
  }) {
    if (item is TimeHeader) {
      return _buildTimeHeader(context, item);
    } else if (item is ImageItem) {
      final hasNext = nextItem != null && nextItem is! TimeHeader;
      return _buildImageBubble(context, item, hasNext: hasNext);
    } else if (item is ComboItem) {
      final hasNext = nextItem != null && nextItem is! TimeHeader;
      return _buildComboItem(context, item, hasNext: hasNext);
    }
    return const SizedBox.shrink();
  }

  /// TimeHeader widget - Separator style
  Widget _buildTimeHeader(BuildContext context, TimeHeader header) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primaryPink,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTimeHeader(header.time),
            style: TextStyle(
              color: AppColors.primaryPink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ImageItem widget - Timeline style
  Widget _buildImageBubble(
    BuildContext context,
    ImageItem item, {
    required bool hasNext,
  }) {
    final image = item.image;
    final gender = item.gender;
    final genderColor = gender == 'male'
        ? AppColors.genderMale
        : AppColors.genderFemale;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline marker và đường nối
          Column(
            children: [
              // Marker tròn
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: genderColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
              // Đường nối dọc (vẽ nếu có item tiếp theo)
              if (hasNext)
                Container(
                  width: 2,
                  height: 20,
                  color: genderColor.withOpacity(0.5),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content card
          Expanded(
            child: GestureDetector(
              onTap: () => _showImageDetail(context, image),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta thời gian
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _formatTime(image.actionAt),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDateShort(image.actionAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Image card
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: image.imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      if (image.mood != null && image.mood!.isNotEmpty)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: _buildMoodChip(image.mood!),
                        ),
                      // EXP badge góc trên phải
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${image.totalExp} EXP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Text caption (nếu có)
                  if (image.text != null && image.text!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        image.text!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChip(String mood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        mood,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ComboItem widget - event card với grid 2 cột
  Widget _buildComboItem(
    BuildContext context,
    ComboItem combo, {
    required bool hasNext,
  }) {
    // Tạm thời dùng màu cam cho combo (có thể cải thiện sau)
    final timelineColor = Colors.orange.shade400;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline marker và đường nối
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: timelineColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
              if (hasNext)
                Container(
                  width: 2,
                  height: 20,
                  color: timelineColor.withOpacity(0.5),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade600, Colors.orange.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'CẢ HAI ĐÃ CHĂM PET',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      // EXP badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${combo.totalExp} EXP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Grid 2 cột hiển thị 2 ảnh
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showImageDetail(context, combo.images[0]),
                        child: _buildComboImageItem(
                          combo.images[0],
                          label: '• YOU',
                          isLeft: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showImageDetail(context, combo.images[1]),
                        child: _buildComboImageItem(
                          combo.images[1],
                          label: '• PARTNER',
                          isLeft: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper để build image item trong combo grid
  Widget _buildComboImageItem(
    PetImage image, {
    required String label,
    required bool isLeft,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: image.imageUrl,
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 120,
              color: Colors.grey.shade800,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 120,
              color: Colors.grey.shade800,
              child: const Icon(Icons.error, color: Colors.white, size: 30),
            ),
          ),
        ),
        // Overlay text
        Positioned(
          bottom: 4,
          left: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(image.actionAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: AppColors.primaryPink.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có khoảnh khắc nào',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy gửi ảnh cho pet để tạo kỷ niệm nhé!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDetail(BuildContext context, PetImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Ảnh full
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: image.imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade900,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.error, color: Colors.white, size: 60),
                ),
              ),
            ),
            // Info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // EXP info
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: image.hasBonus
                                ? AppColors.primaryPink
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${image.totalExp} EXP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (image.hasBonus) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Bonus!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Date
                    Text(
                      _formatDate(image.actionAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    // Caption
                    if (image.text != null && image.text!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        image.text!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  /// Format time header (mốc thời gian)
  String _formatTimeHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hôm nay';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  /// Format time cho message bubble (chỉ giờ:phút)
  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format date ngắn gọn
  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return '';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }
}

class PetMiniStatusBar extends ConsumerWidget {
  const PetMiniStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sceneState = ref.watch(petSceneNotifierProvider);

    if (sceneState.isLoading) {
      return _buildSkeleton();
    }

    final petStatus = sceneState.petSceneData?.petStatus;
    if (petStatus == null) {
      return _buildSkeleton();
    }

    final progress = petStatus.expToNextLevel == 0
        ? 0.0
        : (petStatus.exp / petStatus.expToNextLevel).clamp(0.0, 1.0);
    final feedInfo = petStatus.todayFeedCount > 0
        ? '❤️ ${petStatus.todayFeedCount} khoảnh khắc hôm nay'
        : petStatus.lastFeedTime != null
        ? '⏰ Lần cuối: ${DateFormat('HH:mm').format(petStatus.lastFeedTime!)}'
        : '❤️ Chưa có khoảnh khắc hôm nay';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.pets, color: AppColors.primaryPink, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Lv ${petStatus.level}',
                          style: TextStyle(
                            color: AppColors.primaryPink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              height: 6,
                              child: Stack(
                                children: [
                                  Container(
                                    color: AppColors.primaryPink.withOpacity(
                                      0.15,
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryPink,
                                            AppColors.primaryPinkLight,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${petStatus.exp}/${petStatus.expToNextLevel}',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feedInfo,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
    );
  }
}
