import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/routes/app_routes.dart';

class CoupleConnectionAppBar extends StatelessWidget {
  const CoupleConnectionAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryPinkLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                color: AppColors.primaryPink,
                size: 24,
              ),
            ),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}
