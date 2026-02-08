import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_mini_status_bar.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/core/widgets/app_back_icon.dart';

class PetAlbumHeader extends StatelessWidget {
  final bool canPop;
  final bool isSwipeMode;

  const PetAlbumHeader({
    super.key,
    required this.canPop,
    this.isSwipeMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const AppBackIcon(),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: PetMiniStatusBar()),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (isSwipeMode) {
                context.go(AppRoutes.petAlbum);
              } else {
                context.go(AppRoutes.petAlbumSwipe);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPink.withOpacity(0.3),
                    AppColors.primaryPinkDark.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isSwipeMode
                    ? Icons.grid_view_rounded
                    : Icons.view_carousel_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
