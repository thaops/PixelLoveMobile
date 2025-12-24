import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/models/timeline_item.dart';
import 'package:pixel_love/features/pet_image/presentation/utils/pet_album_formatters.dart';

class TimeHeaderWidget extends StatelessWidget {
  final TimeHeader header;

  const TimeHeaderWidget({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
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
            PetAlbumFormatters.header(header.time),
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
}

