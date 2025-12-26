import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/auth/presentation/controllers/onboarding_controller.dart';
import 'package:pixel_love/features/auth/presentation/widgets/login_section.dart';
import 'package:pixel_love/features/auth/presentation/widgets/onboarding_content.dart';
import 'package:pixel_love/features/auth/presentation/widgets/pagination_dots.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: LoveBackground(child: SafeArea(child: _AuthScreenContent())),
    );
  }
}

class _AuthScreenContent extends ConsumerStatefulWidget {
  const _AuthScreenContent();

  @override
  ConsumerState<_AuthScreenContent> createState() => _AuthScreenContentState();
}

class _AuthScreenContentState extends ConsumerState<_AuthScreenContent> {
  late final PageController _pageController;
  late final OnboardingController _onboardingController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _onboardingController = OnboardingController(
      pageController: _pageController,
    );
  }

  @override
  void dispose() {
    _onboardingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OnboardingContent(pageController: _pageController),
        Positioned(
          left: 32,
          right: 32,
          bottom: 360,
          child: ValueListenableBuilder<int>(
            valueListenable: _onboardingController.currentPageNotifier,
            builder: (context, currentPage, _) {
              return PaginationDots(currentPage: currentPage);
            },
          ),
        ),
        const Positioned(left: 0, right: 0, bottom: 0, child: LoginSection()),
      ],
    );
  }
}
