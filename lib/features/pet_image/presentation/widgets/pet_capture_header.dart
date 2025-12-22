import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';

class PetCaptureHeader extends StatelessWidget {
  const PetCaptureHeader({
    super.key,
    required this.state,
    required this.notifier,
    required this.zoomLevel,
  });

  final PetCaptureState state;
  final PetCaptureNotifier notifier;
  final double zoomLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: notifier.toggleFlash,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Icon(
                _flashIcon(state.flashMode),
                color: state.flashMode == FlashMode.none
                    ? Colors.white.withOpacity(0.5)
                    : AppColors.primaryPink,
                size: 24,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${zoomLevel.toStringAsFixed(1)}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _flashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.none:
        return Icons.flash_off_rounded;
      default:
        return Icons.flash_auto_rounded;
    }
  }
}
