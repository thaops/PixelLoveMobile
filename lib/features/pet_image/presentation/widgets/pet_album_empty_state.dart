import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class PetAlbumEmptyState extends StatelessWidget {
  const PetAlbumEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
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
}

