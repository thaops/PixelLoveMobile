import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_preview_caption.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_preview_close_button.dart';

class PetPreviewImage extends StatelessWidget {
  const PetPreviewImage({
    super.key,
    required this.state,
    required this.notifier,
  });

  final PetCaptureState state;
  final PetCaptureNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (!state.isPreviewMode || state.previewFile == null) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;

    final containerWidth = screenWidth * 0.95;
    final containerHeight = containerWidth * 4 / 3.9;

    return Container(
      width: containerWidth,
      height: containerHeight,
      margin: EdgeInsets.symmetric(
        horizontal: (screenWidth - containerWidth) / 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44),
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(44),
            child: _buildPreview(state.previewFile!),
          ),
          PetPreviewCaption(state: state, notifier: notifier),
          PetPreviewCloseButton(state: state, notifier: notifier),
        ],
      ),
    );
  }

  Widget _buildPreview(File file) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.scale(
          scale: 1.1, 
          child: Image.file(file, fit: BoxFit.cover),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.black.withOpacity(0.2)),
        ),

        // Foreground (ảnh chính)
        Transform.scale(
          scale: 1.05, 
          child: Image.file(file, fit: BoxFit.cover),
        ),
      ],
    );
  }
}
