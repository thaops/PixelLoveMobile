import 'dart:ui';
import 'package:flutter/material.dart';

/// Widget overlay mềm mại cho capture animation
/// Thay thế flash overlay trắng bằng fade animation tinh tế
class CaptureAnimationOverlay extends StatefulWidget {
  const CaptureAnimationOverlay({super.key, required this.isActive});

  final bool isActive;

  @override
  State<CaptureAnimationOverlay> createState() =>
      _CaptureAnimationOverlayState();
}

class _CaptureAnimationOverlayState extends State<CaptureAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Opacity animation: 1.0 → 0.85 → 1.0
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Subtle blur animation: 0 → 3 → 0
    _blurAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 3.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 3.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(CaptureAnimationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive && !_controller.isAnimating) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Tạo hiệu ứng fade mềm mại: overlay mờ dần từ trong suốt → mờ nhẹ → trong suốt
        // Khi opacity animation = 0.85, overlay sẽ có opacity cao hơn để preview fade xuống ~0.85
        // Sử dụng công thức: overlayOpacity = (1.0 - previewOpacity) để đạt preview fade effect
        final targetPreviewOpacity =
            _opacityAnimation.value; // 1.0 → 0.85 → 1.0
        final overlayOpacity =
            (1.0 - targetPreviewOpacity) * 0.2; // Tăng hệ số để fade rõ hơn

        return Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: overlayOpacity,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
