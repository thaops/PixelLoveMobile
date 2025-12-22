import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/routes/app_routes.dart';

class PetCaptureFooter extends StatelessWidget {
  const PetCaptureFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.petAlbum);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_arrow_up_rounded,
              color: AppColors.primaryPink.withOpacity(0.9),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              'Lịch sử',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
