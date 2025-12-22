import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';

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

class PetCaptureActionBarPositioned extends StatelessWidget {
  const PetCaptureActionBarPositioned({
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
    final footerHeight = state.isPreviewMode ? 60.0 : 0.0;
    final bottomPosition =
        footerHeight + (keyboardHeight > 0 ? keyboardHeight * 0.73 : 0);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      left: 0,
      right: 0,
      bottom: bottomPosition,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: state.isPreviewMode ? null : onPickFromGallery,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.photo_library_rounded,
                color: state.isPreviewMode
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white,
                size: 24,
              ),
            ),
          ),
          GestureDetector(
            onTap: state.isPreviewMode
                ? (state.isSending ? null : notifier.send)
                : () async {
                    await onCapture();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryPink, width: 5),
                color: state.isPreviewMode
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: state.isPreviewMode
                    ? const Icon(
                        Icons.send_rounded,
                        key: ValueKey('send'),
                        color: Colors.white,
                        size: 32,
                      )
                    : Container(
                        key: const ValueKey('shutter'),
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          GestureDetector(
            onTap: state.isPreviewMode ? null : notifier.switchCamera,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.cameraswitch_rounded,
                color: state.isPreviewMode
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
