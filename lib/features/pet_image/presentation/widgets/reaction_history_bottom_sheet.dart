import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:intl/intl.dart';

void showReactionHistoryBottomSheet(BuildContext context, PetImage image) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => ReactionHistoryBottomSheet(image: image),
  );
}

class ReactionHistoryBottomSheet extends ConsumerStatefulWidget {
  final PetImage image;

  const ReactionHistoryBottomSheet({super.key, required this.image});

  @override
  ConsumerState<ReactionHistoryBottomSheet> createState() =>
      _ReactionHistoryBottomSheetState();
}

class _ReactionHistoryBottomSheetState
    extends ConsumerState<ReactionHistoryBottomSheet> {
  late PetImage _currentImage;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.image;
    _fetchLatestDetails();
  }

  Future<void> _fetchLatestDetails() async {
    // Không cần trạng thái loading để trải nghiệm mượt mà
    final repository = ref.read(petImageRepositoryProvider);
    final result = await repository.getPetImageDetails(widget.image.id);

    result.when(
      success: (updatedImage) {
        if (mounted) {
          setState(() {
            _currentImage = updatedImage;
          });
        }
      },
      error: (failure) {
        // Im lặng nếu lỗi, giữ nguyên dữ liệu cũ
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Thanh kéo
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text(
                  "Cảm xúc",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_currentImage.reactionTotalCount} lượt",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10),

          // Danh sách
          Expanded(
            child: _currentImage.latestDetails.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _currentImage.latestDetails.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final detail = _currentImage.latestDetails[index];
                      return _buildReactionItem(detail);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 48,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 12),
          Text(
            "Chưa có cảm xúc nào",
            style: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionItem(PetReactionDetail detail) {
    return Row(
      children: [
        // Avatar
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 2),
              ),
              child: ClipOval(
                child: detail.avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: detail.avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.white10),
                        errorWidget: (context, url, error) =>
                            _buildInitials(detail.displayName),
                      )
                    : _buildInitials(detail.displayName),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: Text(detail.emoji, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Tên & Thời gian
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(detail.updatedAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Con số
        if (detail.count > 1)
          Text(
            "x${detail.count}",
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(String name) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : "?";
    return Container(
      color: Colors.blueGrey.withOpacity(0.3),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return "Vừa xong";
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    return DateFormat('dd/MM HH:mm').format(time);
  }
}
