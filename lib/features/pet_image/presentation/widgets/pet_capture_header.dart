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
                color: AppColors.primaryPink.withOpacity(0.05),
                border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                _flashIcon(state.flashMode),
                color: state.flashMode == FlashMode.none
                    ? AppColors.primaryPink.withOpacity(1)
                    : AppColors.primaryPink,
                size: 24,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryPink.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              '${zoomLevel.toStringAsFixed(1)}x',
              style: const TextStyle(
                color: AppColors.primaryPink,
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
