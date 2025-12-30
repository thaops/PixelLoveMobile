import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/capture_button.dart';

class PetCaptureActionBar extends StatelessWidget {
  const PetCaptureActionBar({
    super.key,
    required this.state,
    required this.notifier,
    required this.onPickFromGallery,
    required this.onCapture,
  });

  final PetCaptureState state;
  final PetCaptureNotifier notifier;
  final VoidCallback onPickFromGallery;
  final Future<void> Function() onCapture;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? keyboardHeight : 0),
      child: _ActionBarContent(
        state: state,
        notifier: notifier,
        onPickFromGallery: onPickFromGallery,
        onCapture: onCapture,
      ),
    );
  }
}

class _ActionBarContent extends StatelessWidget {
  const _ActionBarContent({
    required this.state,
    required this.notifier,
    required this.onPickFromGallery,
    required this.onCapture,
  });

  final PetCaptureState state;
  final PetCaptureNotifier notifier;
  final VoidCallback onPickFromGallery;
  final Future<void> Function() onCapture;

  @override
  Widget build(BuildContext context) {
    // Kiểm tra nếu đã freeze
    final isFrozen = state.isFrozen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔥 Khi frozen: hiển thị nút X, khi live: hiển thị gallery
          isFrozen
              ? SizedBox.shrink()
              : GestureDetector(
                  onTap: onPickFromGallery,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryPink.withOpacity(0.05),
                      border: Border.all(
                        color: AppColors.primaryPink.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primaryPink,
                      size: 24,
                    ),
                  ),
                ),
          // Capture button - tự động đổi nút bên trong
          CaptureButton(
            state: state,
            onTap: isFrozen
                ? notifier.send
                : () async {
                    await onCapture();
                  },
          ),
          // 🔥 Khi frozen: hiển thị nút send, khi live: hiển thị switch camera
          isFrozen
              ? const SizedBox.shrink() // Nút send đã có trong CaptureButton
              : GestureDetector(
                  onTap: notifier.switchCamera,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryPink.withOpacity(0.05),
                      border: Border.all(
                        color: AppColors.primaryPink.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.cameraswitch_rounded,
                      color: AppColors.primaryPink,
                      size: 24,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
