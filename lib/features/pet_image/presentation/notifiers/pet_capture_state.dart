import 'dart:io';
import 'package:camerawesome/camerawesome_plugin.dart';

class PetCaptureState {
  const PetCaptureState({
    this.isPreviewMode = false,
    this.isSending = false,
    this.isCapturing = false,
    this.flashMode = FlashMode.none,
    this.previewFile,
    this.capturedAt,
  });

  final bool isPreviewMode;
  final bool isSending;
  final bool isCapturing;
  final FlashMode flashMode;
  final File? previewFile;
  final DateTime? capturedAt;

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
