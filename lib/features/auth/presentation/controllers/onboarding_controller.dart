import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pixel_love/features/auth/presentation/constants/onboarding_data.dart';

/// Controller for managing onboarding page auto-scroll
class OnboardingController {
  final PageController pageController;
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);
  Timer? _autoScrollTimer;

  OnboardingController({required this.pageController}) {
    _setupListener();
    _startAutoScroll();
  }

  int get currentPage => currentPageNotifier.value;

  void _setupListener() {
    pageController.addListener(() {
      final page = pageController.page?.round() ?? 0;
      if (page != currentPageNotifier.value) {
        currentPageNotifier.value = page;
        _resetAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(OnboardingData.autoScrollDuration, (
      timer,
    ) {
      if (pageController.hasClients) {
        final nextPage =
            (currentPageNotifier.value + 1) % OnboardingData.totalPages;
        pageController.animateToPage(
          nextPage,
          duration: OnboardingData.pageAnimationDuration,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _resetAutoScroll() {
    _startAutoScroll();
  }

  void dispose() {
    _autoScrollTimer?.cancel();
    currentPageNotifier.dispose();
    pageController.dispose();
  }
}
