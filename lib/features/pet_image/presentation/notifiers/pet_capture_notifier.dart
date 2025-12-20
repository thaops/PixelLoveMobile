import 'dart:io';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';

/// Pet Capture State
class PetCaptureState {
  final bool isPreviewMode;
  final bool isSending;
  final bool isCapturing;
  final FlashMode flashMode;
  final File? previewFile;
  final DateTime? capturedAt;

  const PetCaptureState({
    this.isPreviewMode = false,
    this.isSending = false,
    this.isCapturing = false,
    this.flashMode = FlashMode.auto,
    this.previewFile,
    this.capturedAt,
  });

  PetCaptureState copyWith({
    bool? isPreviewMode,
    bool? isSending,
    bool? isCapturing,
    FlashMode? flashMode,
    File? previewFile,
    DateTime? capturedAt,
  }) {
    return PetCaptureState(
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      isSending: isSending ?? this.isSending,
      isCapturing: isCapturing ?? this.isCapturing,
      flashMode: flashMode ?? this.flashMode,
      previewFile: previewFile ?? this.previewFile,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }
}

/// Pet Capture Notifier - Handles camera capture and image sending
class PetCaptureNotifier extends Notifier<PetCaptureState> {
  final TextEditingController captionController = TextEditingController();
  PhotoCameraState? _photoState;

  @override
  PetCaptureState build() {
    return const PetCaptureState();
  }

  /// Nhận state từ builder để thao tác chụp/flash/switch camera
  void attachState(CameraState cameraState) {
    cameraState.when(
      onPhotoMode: (photoState) {
        _photoState = photoState;
        state = state.copyWith(flashMode: photoState.sensorConfig.flashMode);
      },
    );
  }

  Future<void> switchCamera() async {
    final state = _photoState;
    if (state == null) return;
    await state.switchCameraSensor();
  }

  Future<void> toggleFlash() async {
    final state = _photoState;
    if (state == null) return;

    FlashMode next;
    switch (this.state.flashMode) {
      case FlashMode.auto:
        next = FlashMode.on;
        break;
      case FlashMode.on:
        next = FlashMode.always;
        break;
      case FlashMode.always:
        next = FlashMode.none;
        break;
      case FlashMode.none:
        next = FlashMode.auto;
        break;
    }
    await state.sensorConfig.setFlashMode(next);
    this.state = this.state.copyWith(flashMode: next);
  }

  Future<void> capturePhoto() async {
    final state = _photoState;
    if (state == null) return;
    if (this.state.isCapturing || this.state.isSending) return;

    this.state = this.state.copyWith(isCapturing: true);
    try {
      HapticFeedback.lightImpact();
      final request = await state.takePhoto();
      final path = _extractPath(request);
      if (path == null || path.isEmpty) {
        // Error sẽ được handle ở UI layer
        return;
      }
      final file = File(path);
      this.state = this.state.copyWith(
        previewFile: file,
        capturedAt: DateTime.now(),
        isPreviewMode: true,
        isCapturing: false,
      );
    } catch (e) {
      // Error sẽ được handle ở UI layer
      this.state = this.state.copyWith(isCapturing: false);
    }
  }

  void resetPreview() {
    captionController.clear();
    state = state.copyWith(
      previewFile: null,
      capturedAt: null,
      isPreviewMode: false,
    );
  }

  Future<void> send() async {
    if (state.previewFile == null) return;
    if (state.isSending) return;

    state = state.copyWith(isSending: true);
    try {
      final cloudinaryService = ref.read(cloudinaryUploadServiceProvider);
      final sendImageUseCase = ref.read(sendImageToPetUseCaseProvider);

      final uploadResult = await cloudinaryService.uploadImage(state.previewFile!);

      await uploadResult.when(
        success: (url) async {
          final text = captionController.text.trim();
          final apiResult = await sendImageUseCase.call(
            imageUrl: url,
            takenAt: state.capturedAt,
            text: text.isEmpty ? null : text,
          );

          apiResult.when(
            success: (_) {
              resetPreview();
              // Success message sẽ được handle ở UI layer
            },
            error: (failure) {
              // Error message sẽ được handle ở UI layer
              state = state.copyWith(isSending: false);
            },
          );
        },
        error: (failure) {
          // Error message sẽ được handle ở UI layer
          state = state.copyWith(isSending: false);
        },
      );
    } catch (e) {
      // Error message sẽ được handle ở UI layer
      state = state.copyWith(isSending: false);
    }
  }

  String? _extractPath(CaptureRequest request) {
    return request.when(
      single: (single) => single.file?.path,
      multiple: (multiple) => multiple.fileBySensor.values.first?.path,
    );
  }
}

/// Provider để dispose captionController khi notifier bị dispose
final petCaptureNotifierDisposerProvider = Provider<void>((ref) {
  ref.onDispose(() {
    final notifier = ref.read(petCaptureNotifierProvider.notifier);
    notifier.captionController.dispose();
  });
});

