import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/auth/presentation/constants/onboarding_data.dart';

/// Pagination dots indicator for onboarding pages
class PaginationDots extends StatelessWidget {
  final int currentPage;

  const PaginationDots({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(OnboardingData.totalPages, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentPage
                ? AppColors.primaryPink
                : AppColors.borderLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
