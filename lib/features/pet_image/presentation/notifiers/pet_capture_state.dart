import 'dart:io';
import 'dart:typed_data';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class PetCaptureState {
  const PetCaptureState({
    this.isFrozen = false,
    this.isSending = false,
    this.isCapturing = false,
    this.flashMode = FlashMode.none,
    this.bytes,
    this.previewFile,
    this.capturedAt,
  });

  final bool isFrozen;      // 🔥 Freeze preview chưa
  final bool isSending;
  final bool isCapturing;
  final FlashMode flashMode;
  final Uint8List? bytes;   // 🔥 Frame frozen từ RAM
  final File? previewFile;  // 🔥 Chỉ dùng khi send (background)
  final DateTime? capturedAt; // 🔥 Giữ lại cho send API (takenAt)

  // 🔥 Helper: Tạo ImageProvider từ bytes
  ImageProvider? get previewImageProvider {
    if (bytes == null) return null;
    return MemoryImage(bytes!);
  }

  PetCaptureState copyWith({
    bool? isFrozen,
    bool? isSending,
    bool? isCapturing,
    FlashMode? flashMode,
    Uint8List? bytes,
    bool clearBytes = false,
    File? previewFile,
    DateTime? capturedAt,
  }) {
    return PetCaptureState(
      isFrozen: isFrozen ?? this.isFrozen,
      isSending: isSending ?? this.isSending,
      isCapturing: isCapturing ?? this.isCapturing,
      flashMode: flashMode ?? this.flashMode,
      bytes: clearBytes ? null : (bytes ?? this.bytes),
      previewFile: previewFile ?? this.previewFile,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }
}
