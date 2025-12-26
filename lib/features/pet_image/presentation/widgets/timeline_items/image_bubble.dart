import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/models/timeline_item.dart';
import 'package:pixel_love/features/pet_image/presentation/utils/pet_album_formatters.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_image_detail_dialog.dart';

class ImageBubble extends StatelessWidget {
  final ImageItem item;
  final bool hasNext;

  const ImageBubble({super.key, required this.item, required this.hasNext});

  @override
  Widget build(BuildContext context) {
    final genderColor = item.gender == 'male'
        ? AppColors.genderMale
        : AppColors.genderFemale;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: genderColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
              if (hasNext)
                Container(
                  width: 2,
                  height: 20,
                  color: genderColor.withOpacity(0.5),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => showPetImageDetailDialog(context, item.image),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaBar(item: item),
                  const SizedBox(height: 8),
                  _ImageCard(imageItem: item),
                  if (item.image.text != null &&
                      item.image.text!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _Caption(text: item.image.text!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBar extends StatelessWidget {
  final ImageItem item;

  const _MetaBar({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            PetAlbumFormatters.time(item.image.actionAt),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            PetAlbumFormatters.shortDate(item.image.actionAt),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final ImageItem imageItem;

  const _ImageCard({required this.imageItem});

  @override
  Widget build(BuildContext context) {
    // Tỉ lệ cố định để giữ khung ổn định khi loading
    const aspectRatio = 4 / 3;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: CachedNetworkImage(
              imageUrl: imageItem.image.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              memCacheHeight: 600,
              maxWidthDiskCache: 1200,
              maxHeightDiskCache: 1200,

              useOldImageOnUrlChange: true,
              placeholder: (context, url) => Container(
                width: double.infinity,
                color: Colors.grey.shade800,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                color: Colors.grey.shade800,
                child: const Icon(Icons.error, color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
        if (imageItem.image.mood != null && imageItem.image.mood!.isNotEmpty)
          Positioned(
            left: 8,
            bottom: 8,
            child: _MoodChip(mood: imageItem.image.mood!),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 4),
                Text(
                  '${imageItem.image.totalExp} EXP',
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
    );
  }
}

class _Caption extends StatelessWidget {
  final String text;

  const _Caption({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String mood;

  const _MoodChip({required this.mood});

  @override
  Widget build(BuildContext context) {
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
}
