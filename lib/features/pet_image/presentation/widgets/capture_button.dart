import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';

/// Capture button với scale animation mềm mại
/// Scale: 1.0 → 0.92 → 1.0 trong 120ms
class CaptureButton extends StatefulWidget {
  const CaptureButton({super.key, required this.state, required this.onTap});

  final PetCaptureState state;
  final VoidCallback onTap;

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.92,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.92,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_scaleController);
  }

  void _handleTap() {
    // Disable khi đang capture hoặc đang sending
    if (widget.state.isCapturing ||
        (widget.state.isFrozen && widget.state.isSending)) {
      return;
    }
    _scaleController.forward(from: 0.0);
    widget.onTap();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryPink, width: 5),
                color: widget.state.isFrozen
                    ? AppColors.primaryPink
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: widget.state.isFrozen
                  ? const Icon(
                      Icons.send_rounded,
                      color: AppColors.backgroundLight,
                      size: 32,
                    )
                  : Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryPink,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
