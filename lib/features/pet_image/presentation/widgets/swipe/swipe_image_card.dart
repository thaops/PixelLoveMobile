import 'dart:typed_data';
import 'dart:ui';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/reaction_history_bottom_sheet.dart';

class SwipeImageCard extends StatelessWidget {
  final PetImage? image; // 🔥 Cho phép null cho trạng thái chưa lên server
  final double cardWidth;
  final double cardHeight;
  final bool isNextCard;
  final bool isFromPartner;
  final bool isLastImage;
  final bool showMemoryHighlight;
  final Animation<double> shimmerAnimation;
  final IconData memoryIcon;
  final String formattedDate;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final Uint8List? localImageBytes;
  final int? localRotation;
  final SensorPosition? localPosition;
  final bool isUploading; // 🔥 Thêm trạng thái đang gửi
  final String? localCaption; // 🔥 Thêm caption local

  const SwipeImageCard({
    super.key,
    this.image,
    required this.cardWidth,
    required this.cardHeight,
    required this.isNextCard,
    required this.isFromPartner,
    required this.isLastImage,
    required this.showMemoryHighlight,
    required this.shimmerAnimation,
    required this.memoryIcon,
    required this.formattedDate,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    this.localImageBytes,
    this.localRotation,
    this.localPosition,
    this.isUploading = false,
    this.localCaption,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        width: cardWidth,
        height: cardHeight,
        constraints: BoxConstraints(maxWidth: cardWidth, maxHeight: cardHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(44),
          color: localImageBytes != null ? Colors.transparent : Colors.black,
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
              // 🔥 1. Lớp nền: Hiển thị ngay ảnh local nếu có, xoay đúng hướng
              if (localImageBytes != null)
                Center(
                  child: RotatedBox(
                    quarterTurns: (localRotation ?? 0) ~/ 90,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(
                          localPosition == SensorPosition.front ? -1.0 : 1.0,
                          1.0,
                        ),
                      child: Image.memory(
                        localImageBytes!,
                        width: ((localRotation ?? 0) ~/ 90) % 2 != 0
                            ? cardHeight
                            : cardWidth,
                        height: ((localRotation ?? 0) ~/ 90) % 2 != 0
                            ? cardWidth
                            : cardHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

              // 🔥 2. Lớp trên: Ảnh từ API (chỉ hiện đè lên khi đã tải xong)
              if (image != null)
                CachedNetworkImage(
                  imageUrl: image!.imageUrl,
                  fit: BoxFit.cover,
                  color: isNextCard ? Colors.black.withOpacity(0.3) : null,
                  colorBlendMode: isNextCard ? BlendMode.darken : null,
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
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
                  placeholder: (context, url) => localImageBytes != null
                      ? const SizedBox.shrink()
                      : _buildSkeletonPlaceholder(),
                  fadeOutDuration: Duration.zero,
                  fadeInDuration: localImageBytes != null
                      ? Duration.zero
                      : const Duration(milliseconds: 100),
                  errorWidget: (context, url, error) =>
                      (localImageBytes != null)
                      ? const SizedBox.shrink()
                      : Container(
                          color: AppColors.backgroundLight,
                          child: const Center(child: Icon(Icons.error_outline)),
                        ),
                ),
              _buildGradientOverlay(context),
              _buildDateBadge(),
              if (isLastImage) _buildLastImageBadge(),
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
        animation: shimmerAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + shimmerAnimation.value * 2, 0),
                end: Alignment(1.0 + shimmerAnimation.value * 2, 0),
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

  Widget _buildGradientOverlay(BuildContext context) {
    final displayCaption = image?.text ?? localCaption;
    final int displayExp = image?.totalExp ?? 20;

    return Positioned(
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
            if (displayCaption != null && displayCaption.isNotEmpty)
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
                  displayCaption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (isFromPartner) _buildPartnerBadge(),
            _buildInfoRow(context, displayExp),
            if (image?.mood != null && image!.mood!.isNotEmpty)
              _buildMoodBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          const Icon(Icons.favorite, color: Colors.white, size: 14),
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
    );
  }

  Widget _buildInfoRow(BuildContext context, int totalExp) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isUploading
                ? Colors.white.withOpacity(0.3)
                : AppColors.primaryPink,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isUploading)
                BoxShadow(
                  color: AppColors.primaryPink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUploading ? Icons.access_time_rounded : Icons.star,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isUploading ? 'Đang gửi...' : '+$totalExp EXP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (image?.hasBonus ?? false) ...[
                const SizedBox(width: 6),
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
        if (image != null && (image!.reactionTotalCount) > 0) ...[
          const SizedBox(width: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => showReactionHistoryBottomSheet(context, image!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...image!.reactionGroups
                      .take(3)
                      .map(
                        (g) => Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Text(
                            g.emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                  const SizedBox(width: 6),
                  Text(
                    image!.reactionTotalCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateBadge() {
    return Positioned(
      top: isLastImage ? 60 : 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: showMemoryHighlight
              ? AppColors.primaryPink.withOpacity(0.9)
              : Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(memoryIcon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              formattedDate,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mood, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            image?.mood ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLastImageBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
    );
  }
}
