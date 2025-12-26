import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/auth/presentation/constants/onboarding_data.dart';

/// Onboarding content widget with PageView
class OnboardingContent extends StatelessWidget {
  final PageController pageController;

  const OnboardingContent({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: OnboardingData.totalPages,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return _buildPage(index);
      },
    );
  }

  Widget _buildPage(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildIllustration(index),
          _buildTitle(index),
          const SizedBox(height: 8),
          _buildSubtitle(index),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIllustration(int index) {
    return AnimatedSwitcher(
      duration: OnboardingData.pageAnimationDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Center(
        key: ValueKey(index),
        child: Image.asset(
          OnboardingData.imagePaths[index],
          width: 230,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image, size: 100, color: Colors.grey);
          },
        ),
      ),
    );
  }

  Widget _buildTitle(int index) {
    return AnimatedSwitcher(
      duration: OnboardingData.pageAnimationDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.1, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Align(
        key: ValueKey('title_$index'),
        alignment: Alignment.centerLeft,
        child: Text(
          OnboardingData.titles[index],
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildSubtitle(int index) {
    return AnimatedSwitcher(
      duration: OnboardingData.pageAnimationDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.1, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Align(
        key: ValueKey('subtitle_$index'),
        alignment: Alignment.centerLeft,
        child: Text(
          OnboardingData.subtitles[index],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
