import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class PetCaptureState {
  const PetCaptureState({
    this.isFrozen = false,
    this.isSending = false,
    this.isCapturing = false,
    this.flashMode = FlashMode.none,
    this.bytes,
    this.frozenImage,
    this.previewFile,
    this.capturedAt,
    this.sensorRotation = 0,
    this.sensorPosition = SensorPosition.back,
  });

  final bool isFrozen;
  final bool isSending;
  final bool isCapturing;
  final FlashMode flashMode;
  final Uint8List? bytes;
  final ui.Image? frozenImage;
  final File? previewFile;
  final DateTime? capturedAt;
  final int sensorRotation;
  final SensorPosition sensorPosition;

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
    ui.Image? frozenImage,
    bool clearBytes = false,
    File? previewFile,
    DateTime? capturedAt,
    int? sensorRotation,
    SensorPosition? sensorPosition,
  }) {
    return PetCaptureState(
      isFrozen: isFrozen ?? this.isFrozen,
      isSending: isSending ?? this.isSending,
      isCapturing: isCapturing ?? this.isCapturing,
      flashMode: flashMode ?? this.flashMode,
      bytes: clearBytes ? null : (bytes ?? this.bytes),
      frozenImage: clearBytes ? null : (frozenImage ?? this.frozenImage),
      previewFile: previewFile ?? this.previewFile,
      capturedAt: capturedAt ?? this.capturedAt,
      sensorRotation: sensorRotation ?? this.sensorRotation,
      sensorPosition: sensorPosition ?? this.sensorPosition,
    );
  }
}
