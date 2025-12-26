import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/presentation/models/timeline_item.dart';
import 'package:pixel_love/features/pet_image/presentation/utils/pet_album_formatters.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_image_detail_dialog.dart';

class ComboItemWidget extends StatelessWidget {
  final ComboItem combo;
  final bool hasNext;

  const ComboItemWidget({
    super.key,
    required this.combo,
    required this.hasNext,
  });

  @override
  Widget build(BuildContext context) {
    final timelineColor = Colors.orange.shade400;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ComboHeader(combo: combo),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            showPetImageDetailDialog(context, combo.images[0]),
                        child: _ComboImage(
                          image: combo.images[0],
                          label: '• YOU',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            showPetImageDetailDialog(context, combo.images[1]),
                        child: _ComboImage(
                          image: combo.images[1],
                          label: '• PARTNER',
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
}

class _ComboHeader extends StatelessWidget {
  final ComboItem combo;

  const _ComboHeader({required this.combo});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }
}

class _ComboImage extends StatelessWidget {
  final PetImage image;
  final String label;

  const _ComboImage({required this.image, required this.label});

  @override
  Widget build(BuildContext context) {
    const aspectRatio = 4 / 3;
    
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: CachedNetworkImage(
              imageUrl: image.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              memCacheHeight: 600,
              maxWidthDiskCache: 800,
              maxHeightDiskCache: 800,
              fadeInDuration: const Duration(milliseconds: 200),
              fadeOutDuration: const Duration(milliseconds: 100),
              useOldImageOnUrlChange: true,
              placeholder: (context, url) => Container(
                width: double.infinity,
                color: Colors.grey.shade800,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
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
                child: const Icon(Icons.error, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
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
                  PetAlbumFormatters.time(image.actionAt),
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
}

