import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class CustomLoadingWidget extends StatefulWidget {
  final String avatarPath;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Duration duration;
  final bool showBackdrop;

  const CustomLoadingWidget({
    super.key,
    this.avatarPath = 'assets/images/avata-female.png',
    this.size = 120,
    this.borderColor = AppColors.primaryPink,
    this.borderWidth = 6,
    this.duration = const Duration(seconds: 2),
    this.showBackdrop = true,
  });

  @override
  State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    // Bắt đầu xoay ngay lập tức
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize =
        widget.size * 0.55; // Avatar nhỏ hơn để có khoảng cách rộng hơn

    final loadingWidget = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating border circle
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.borderColor,
                      width: widget.borderWidth,
                    ),
                  ),
                ),
              );
            },
          ),
          // Fixed avatar image inside
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset(widget.avatarPath, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );

    // Nếu có backdrop, chỉ thêm một lớp blur nhẹ xung quanh widget
    // Backdrop fill toàn màn hình nên được xử lý ở parent widget
    if (widget.showBackdrop) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: loadingWidget,
      );
    }

    return loadingWidget;
  }
}
