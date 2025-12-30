import 'package:flutter/material.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';

class PetPreviewCloseButton extends StatelessWidget {
  const PetPreviewCloseButton({
    super.key,
    required this.state,
    required this.notifier,
  });

  final PetCaptureState state;
  final PetCaptureNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (!state.isFrozen) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      left: 12,
      child: GestureDetector(
        onTap: notifier.resetPreview,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.6),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
