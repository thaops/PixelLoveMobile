import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';
import 'package:pixel_love/features/pet_image/presentation/utils/image_crop_utils.dart';
import 'package:image/image.dart' as img;

class PetCaptureNotifier extends Notifier<PetCaptureState> {
  final TextEditingController captionController = TextEditingController();
  PhotoCameraState? _photoState;

  // Tỉ lệ khung preview (phải khớp với mask & khung hiển thị review)
  // Đã đổi từ 4/3.5 về 4/3 để khớp với sensor ratio_4_3
  static const double _previewAspectRatio = 4 / 3;

  @override
  PetCaptureState build() {
    return const PetCaptureState();
  }

  /// Nhận state từ builder để thao tác chụp/flash/switch camera
  void attachState(CameraState cameraState) {
    cameraState.when(
      onPhotoMode: (photoState) {
        _photoState = photoState;
        final newFlashMode = photoState.sensorConfig.flashMode;
        // Only update if flashMode changed and delay to avoid modifying during build
        if (state.flashMode != newFlashMode) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            state = state.copyWith(flashMode: newFlashMode);
          });
        }
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
      final originalFile = File(path);
      final croppedFile = await _cropToPreviewAspect(originalFile);
      this.state = this.state.copyWith(
        // Luôn dùng file đã crop (nếu crop lỗi thì dùng ảnh gốc)
        previewFile: croppedFile ?? originalFile,
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

  void setPreviewFile(File file) {
    // Khi chọn từ gallery cũng crop lại theo khung preview
    _cropToPreviewAspect(file).then((cropped) {
      state = state.copyWith(
        previewFile: cropped ?? file,
        capturedAt: DateTime.now(),
        isPreviewMode: true,
      );
    });
  }

  Future<void> send() async {
    if (state.previewFile == null) return;
    if (state.isSending) return;

    state = state.copyWith(isSending: true);
    try {
      final cloudinaryService = ref.read(cloudinaryUploadServiceProvider);
      final sendImageUseCase = ref.read(sendImageToPetUseCaseProvider);

      final uploadResult = await cloudinaryService.uploadImage(
        state.previewFile!,
      );

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
              // Reset preview and stop loading
              resetPreview();
              state = state.copyWith(isSending: false);
              // Success message và navigation sẽ được handle ở UI layer
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

  /// Crop ảnh theo tỉ lệ khung preview để:
  /// - Màn review hiển thị gần giống lúc chụp
  /// - Ảnh gửi lên server đúng với những gì user thấy trong khung
  Future<File?> _cropToPreviewAspect(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final cropped = cropCenterToAspect(
        image,
        targetAspect: _previewAspectRatio,
      );

      final encoded = img.encodeJpg(cropped, quality: 90);
      await file.writeAsBytes(encoded, flush: true);
      return file;
    } catch (_) {
      // Nếu có lỗi (file hỏng, decode fail, ...) thì trả null để dùng ảnh gốc
      return null;
    }
  }
}

/// Provider để dispose captionController khi notifier bị dispose
final petCaptureNotifierDisposerProvider = Provider<void>((ref) {
  ref.onDispose(() {
    final notifier = ref.read(petCaptureNotifierProvider.notifier);
    notifier.captionController.dispose();
  });
});
