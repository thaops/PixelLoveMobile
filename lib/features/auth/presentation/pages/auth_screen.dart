import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_love/features/auth/presentation/controllers/auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFE5F1), // Pastel pink
              const Color(0xFFFFF4E6), // Cream yellow
              const Color(0xFFE8F5E9), // Pastel green
            ],
          ),
        ),
        child: SafeArea(child: _AuthScreenContent(controller: controller)),
      ),
    );
  }
}

class _AuthScreenContent extends StatefulWidget {
  final AuthController controller;

  const _AuthScreenContent({required this.controller});

  @override
  State<_AuthScreenContent> createState() => _AuthScreenContentState();
}

class _AuthScreenContentState extends State<_AuthScreenContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildOnboardingContent()),
        _buildLoginSection(),
      ],
    );
  }

  Widget _buildOnboardingContent() {
    return PageView.builder(
      controller: _pageController,
      itemCount: 3,
      itemBuilder: (context, index) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildIllustration(index),
                const SizedBox(height: 40),
                _buildTitle(index),
                const SizedBox(height: 12),
                _buildSubtitle(index),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIllustration(int index) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background bubbles
          ...List.generate(3, (i) {
            return Positioned(
              left: i * 60.0,
              top: i * 40.0,
              child: Container(
                width: 40 - (i * 8),
                height: 40 - (i * 8),
                decoration: BoxDecoration(
                  color: _getBubbleColor(index, i).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          // Main illustration based on index
          _buildCoupleIllustration(index),
        ],
      ),
    );
  }

  Widget _buildCoupleIllustration(int index) {
    switch (index) {
      case 0:
        return _buildIllustration1();
      case 1:
        return _buildIllustration2();
      case 2:
        return _buildIllustration3();
      default:
        return _buildIllustration1();
    }
  }

  Widget _buildIllustration1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPerson(Colors.pink.shade200, Icons.favorite),
        const SizedBox(width: 20),
        _buildPerson(Colors.blue.shade200, Icons.favorite),
      ],
    );
  }

  Widget _buildIllustration2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPerson(Colors.pink.shade200, Icons.chat_bubble_outline),
            const SizedBox(width: 20),
            _buildPerson(Colors.blue.shade200, Icons.chat_bubble_outline),
          ],
        ),
        const SizedBox(height: 16),
        Icon(Icons.favorite, color: Colors.red.shade300, size: 32),
      ],
    );
  }

  Widget _buildIllustration3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPerson(Colors.pink.shade200, Icons.celebration),
            const SizedBox(width: 20),
            _buildPerson(Colors.blue.shade200, Icons.celebration),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber.shade300, size: 24),
            const SizedBox(width: 8),
            Icon(Icons.star, color: Colors.amber.shade300, size: 24),
            const SizedBox(width: 8),
            Icon(Icons.star, color: Colors.amber.shade300, size: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildPerson(Color color, IconData icon) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 36),
    );
  }

  Color _getBubbleColor(int pageIndex, int bubbleIndex) {
    final colors = [
      [Colors.pink.shade200, Colors.purple.shade200, Colors.blue.shade200],
      [Colors.orange.shade200, Colors.yellow.shade200, Colors.green.shade200],
      [Colors.cyan.shade200, Colors.teal.shade200, Colors.indigo.shade200],
    ];
    return colors[pageIndex][bubbleIndex % 3];
  }

  Widget _buildTitle(int index) {
    final titles = [
      'Kết nối tình yêu',
      'Trò chuyện thân mật',
      'Tạo kỷ niệm đẹp',
    ];
    return Text(
      titles[index],
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF4A4A4A),
        letterSpacing: -0.5,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(int index) {
    final subtitles = [
      'Tìm kiếm và kết nối với người bạn đời của bạn một cách dễ dàng và an toàn',
      'Trò chuyện riêng tư, chia sẻ khoảnh khắc đáng nhớ với người thương',
      'Lưu giữ những kỷ niệm đẹp, tạo album ảnh và nhật ký tình yêu của bạn',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        subtitles[index],
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF7A7A7A),
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoginSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPaginationDots(),
          const SizedBox(height: 32),
          Obx(() {
            if (widget.controller.isLoading) {
              return const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
              );
            }

            return Column(
              children: [
                _buildPrimaryButton(
                  onPressed: widget.controller.loginWithGoogle,
                  icon: Icons.g_mobiledata,
                  label: 'Đăng nhập với Google',
                  backgroundColor: const Color(0xFFFF6B9D),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 16),
                _buildSecondaryButton(
                  onPressed: () {
                    // TODO: Implement email login
                    Get.snackbar(
                      'Thông báo',
                      'Tính năng đăng nhập bằng Email đang được phát triển',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: Icons.email_outlined,
                  label: 'Đăng nhập với Email',
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          Obx(() {
            if (widget.controller.errorMessage.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.controller.errorMessage,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? const Color(0xFFFF6B9D)
                : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF7A7A7A), size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
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
                color: const Color(0xFFFF6B9D),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' và '),
            TextSpan(
              text: 'Chính sách bảo mật',
              style: TextStyle(
                color: const Color(0xFFFF6B9D),
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
