import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/auth/notifiers/auth_notifier.dart';
import 'package:pixel_love/features/auth/providers/auth_providers.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: LoveBackground(
        child: SafeArea(child: _AuthScreenContent()),
      ),
    );
  }
}

class _AuthScreenContent extends ConsumerStatefulWidget {
  const _AuthScreenContent();

  @override
  ConsumerState<_AuthScreenContent> createState() => _AuthScreenContentState();
}

class _AuthScreenContentState extends ConsumerState<_AuthScreenContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
        _resetAutoScroll();
      }
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _resetAutoScroll() {
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildOnboardingContent(),
        Positioned(
          left: 32,
          right: 32,
          bottom: 360,
          child: _buildPaginationDots(),
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: _buildLoginSection()),
      ],
    );
  }

  Widget _buildOnboardingContent() {
    return PageView.builder(
      controller: _pageController,
      itemCount: 3,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
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
                  child: _buildIllustration(index),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
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
                child: _buildTitle(index, key: ValueKey('title_$index')),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
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
                child: _buildSubtitle(index, key: ValueKey('subtitle_$index')),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIllustration(int index) {
    final imagePaths = [
      'assets/images/img-couple1.png',
      'assets/images/img-couple2.png',
      'assets/images/img-couple3.png',
    ];

    return Image.asset(
      imagePaths[index],
      width: 230,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.image, size: 100, color: Colors.grey);
      },
    );
  }

  Widget _buildTitle(int index, {Key? key}) {
    final titles = [
      'Kết nối tình yêu',
      'Trò chuyện thân mật',
      'Tạo kỷ niệm đẹp',
    ];
    return Align(
      key: key,
      alignment: Alignment.centerLeft,
      child: Text(
        titles[index],
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildSubtitle(int index, {Key? key}) {
    final subtitles = [
      'Tìm kiếm và kết nối với người bạn đời của bạn một cách dễ dàng và an toàn',
      'Trò chuyện riêng tư, chia sẻ khoảnh khắc đáng nhớ với người thương',
      'Lưu giữ những kỷ niệm đẹp, tạo album ảnh và nhật ký tình yêu của bạn',
    ];
    return Align(
      key: key,
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Text(
          subtitles[index],
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

  Widget _buildLoginSection() {
    final authState = ref.watch(authNotifierProvider);
    
    // Handle navigation after successful login
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous != null && previous.isLoading && !next.isLoading) {
        if (next.currentUser != null && next.errorMessage == null) {
          final user = next.currentUser!;
          
          // Navigate based on user state
          if (!user.isOnboarded) {
            context.go(AppRoutes.onboard);
          } else if (user.mode == 'solo') {
            context.go(AppRoutes.coupleConnection);
          } else if (user.mode == 'couple') {
            final hasPartner = user.partnerId != null && user.partnerId!.isNotEmpty;
            final hasCoupleRoom = user.coupleRoomId != null && user.coupleRoomId!.isNotEmpty;
            
            if (hasCoupleRoom || hasPartner) {
              context.go(AppRoutes.home);
            } else {
              context.go(AppRoutes.coupleConnection);
            }
          } else {
            context.go(AppRoutes.coupleConnection);
          }
        }
      }
    });
    
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/img-login-section.png'),
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (authState.isLoading)
              const SizedBox(
                height: 56,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              )
            else
              Column(
                spacing: 16,
                children: [
                  _buildPrimaryButton(
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).loginWithGoogle();
                    },
                    imagePath: 'assets/images/img-google.png',
                    label: 'Đăng nhập với Google',
                    backgroundColor: AppColors.primaryPink,
                    textColor: Colors.white,
                  ),
                  // _buildPrimaryButton(
                  //   onPressed: () {
                  //     ref.read(authNotifierProvider.notifier).loginWithGoogle();
                  //   },
                  //   imagePath: 'assets/images/img-fb.png',
                  //   label: 'Đăng nhập với Facebook',
                  //   backgroundColor: const Color.fromARGB(255, 38, 139, 227),
                  //   textColor: Colors.white,
                  // ),
                ],
              ),
            const SizedBox(height: 24),
            if (authState.errorMessage != null && authState.errorMessage!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.iconRed, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.errorIcon,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        authState.errorMessage!,
                        style: TextStyle(
                          color: AppColors.errorText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? AppColors.primaryPink
                : AppColors.borderLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String imagePath,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(imagePath, width: 24, height: 24),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
          children: [
            const TextSpan(text: 'Bằng cách tiếp tục, bạn đồng ý với '),
            TextSpan(
              text: 'Điều khoản sử dụng',
              style: TextStyle(
                color: AppColors.primaryPink,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' và '),
            TextSpan(
              text: 'Chính sách bảo mật',
              style: TextStyle(
                color: AppColors.primaryPink,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' của chúng tôi'),
          ],
        ),
      ),
    );
  }
}
