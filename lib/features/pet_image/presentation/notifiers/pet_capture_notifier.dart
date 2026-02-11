import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';

import 'pet_capture_state.dart';

/// Helper class for background image processing to avoid UI freeze
class ImageProcessUtils {
  static void convertNV21ToRGBA(Map<String, dynamic> params) {
    final Uint8List nv21Bytes = params['bytes'];
    final int width = params['width'];
    final int height = params['height'];
    final SendPort sendPort = params['sendPort'];

    final Uint8List rgbaBytes = Uint8List(width * height * 4);
    final ySize = width * height;
    int rgbaIndex = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * width + x;
        final yValue = nv21Bytes[yIndex];

        final uvIndex = ySize + ((y ~/ 2) * width) + (x ~/ 2) * 2;
        final vValue = uvIndex < nv21Bytes.length ? nv21Bytes[uvIndex] : 128;
        final uValue = uvIndex + 1 < nv21Bytes.length
            ? nv21Bytes[uvIndex + 1]
            : 128;

        final r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
        final g = (yValue - 0.344 * (uValue - 128) - 0.714 * (vValue - 128))
            .round()
            .clamp(0, 255);
        final b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);

        rgbaBytes[rgbaIndex++] = r;
        rgbaBytes[rgbaIndex++] = g;
        rgbaBytes[rgbaIndex++] = b;
        rgbaBytes[rgbaIndex++] = 255; // Alpha
      }
    }
    sendPort.send(rgbaBytes);
  }
}

class PetCaptureNotifier extends Notifier<PetCaptureState> {
  PhotoCameraState? _photoState;
  final captionController = TextEditingController();
  bool _isCapturingInProgress = false;
  AnalysisImage? _latestFrame;

  SensorPosition _sensorPosition = SensorPosition.back;
  int _sensorRotation = 0;
  double _currentZoom = 1.0;

  static const double _previewAspectRatio = 4 / 3.9;

  @override
  PetCaptureState build() {
    return const PetCaptureState();
  }

  void attachState(CameraState cameraState) {
    cameraState.when(
      onPhotoMode: (photoState) {
        final newFlash = photoState.sensorConfig.flashMode;
        final newPosition = photoState.sensorConfig.sensors.first.position;
        final hasChanged =
            _photoState != photoState ||
            state.flashMode != newFlash ||
            state.sensorPosition != newPosition;

        _photoState = photoState;

        if (state.flashMode != newFlash ||
            state.sensorPosition != newPosition) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.flashMode != newFlash ||
                state.sensorPosition != newPosition) {
              state = state.copyWith(
                flashMode: newFlash,
                sensorPosition: newPosition,
              );
            }
          });
        }

        _updateZoomFromCamera();
        _sensorPosition = newPosition ?? SensorPosition.back;

        if (hasChanged) {
          debugPrint(
            'Camera attached: position=$_sensorPosition zoom=$_currentZoom',
          );
        }
      },
    );
  }

  void _updateZoomFromCamera() {
    final ps = _photoState;
    if (ps == null) return;

    try {
      _currentZoom = ps.sensorConfig.zoom;
    } catch (_) {
      _currentZoom = 1.0;
    }
  }

  int _rotationToDegrees(dynamic rotation) {
    final rotationStr = rotation.toString();
    if (rotationStr.contains('90')) return 90;
    if (rotationStr.contains('180')) return 180;
    if (rotationStr.contains('270')) return 270;
    return 0;
  }

  void onLiveFrame(AnalysisImage image) {
    _latestFrame = image;
    image.when(
      nv21: (nv21) {
        _sensorRotation = _rotationToDegrees(nv21.rotation);
      },
      bgra8888: (bgra) {
        _sensorRotation = _rotationToDegrees(bgra.rotation);
      },
    );
  }

  Future<void> freezeFromLiveFrame() async {
    if (state.isFrozen || _latestFrame == null) return;

    state = state.copyWith(isCapturing: true);

    try {
      _updateZoomFromCamera();
      final uiImage = await _convertAnalysisImage(_latestFrame!);

      state = state.copyWith(
        isFrozen: true,
        frozenImage: uiImage,
        isCapturing: false,
        capturedAt: DateTime.now(),
        sensorRotation: _sensorRotation,
        sensorPosition: _sensorPosition,
      );

      // Defer bytes conversion to avoid heavy blocking
      Future.microtask(() async {
        try {
          final data = await uiImage.toByteData(format: ui.ImageByteFormat.png);
          if (data != null && state.isFrozen) {
            state = state.copyWith(bytes: data.buffer.asUint8List());
          }
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('Freeze error: $e');
      state = state.copyWith(isCapturing: false);
    }
  }

  Future<void> capturePhoto() async {
    if (state.isCapturing ||
        state.isSending ||
        state.isFrozen ||
        _isCapturingInProgress) {
      return;
    }

    final ps = _photoState;
    if (ps == null) return;

    _isCapturingInProgress = true;
    state = state.copyWith(isCapturing: true);

    try {
      final request = await ps.takePhoto();
      final path = _extractPath(request);

      if (path == null) {
        state = state.copyWith(isCapturing: false);
        return;
      }

      final file = File(path);
      final bytes = await file.readAsBytes();

      state = state.copyWith(
        isFrozen: true,
        bytes: bytes,
        previewFile: file,
        capturedAt: DateTime.now(),
        isCapturing: false,
      );
    } catch (e) {
      state = state.copyWith(isCapturing: false);
    } finally {
      _isCapturingInProgress = false;
    }
  }

  Future<File?> _processFileForUpload(File originalFile) async {
    try {
      final originalBytes = await originalFile.readAsBytes();
      var image = img.decodeImage(originalBytes);
      if (image == null) return null;

      if (state.sensorRotation != 0) {
        image = img.copyRotate(image, angle: state.sensorRotation);
      }
      if (state.sensorPosition == SensorPosition.front) {
        image = img.flipHorizontal(image);
      }

      var processed = _cropCenter(image, _previewAspectRatio);

      const int minLongestSide = 1280;
      final longestSide = processed.width > processed.height
          ? processed.width
          : processed.height;

      int targetWidth = processed.width;
      int targetHeight = processed.height;

      if (longestSide < minLongestSide) {
        final scale = minLongestSide / longestSide;
        targetWidth = (processed.width * scale).round();
        targetHeight = (processed.height * scale).round();
        processed = img.copyResize(
          processed,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final tempProcessedFile = File(
        '${tempDir.path}/pet_processed_$timestamp.jpg',
      );
      final encoded = img.encodeJpg(processed, quality: 90);
      await tempProcessedFile.writeAsBytes(encoded);

      final compressedBytes = await FlutterImageCompress.compressWithFile(
        tempProcessedFile.absolute.path,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: 90,
        keepExif: false,
      );

      if (compressedBytes == null) {
        return tempProcessedFile;
      }

      final finalFile = File('${tempDir.path}/pet_$timestamp.jpg');
      await finalFile.writeAsBytes(compressedBytes);

      try {
        await tempProcessedFile.delete();
      } catch (_) {}

      return finalFile;
    } catch (_) {
      return null;
    }
  }

  void resetPreview() {
    captionController.clear();
    _isCapturingInProgress = false;
    _latestFrame = null;
    state = state.copyWith(
      isFrozen: false,
      clearBytes: true,
      previewFile: null,
      capturedAt: null,
    );
  }

  Future<void> setPreviewFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      state = state.copyWith(
        isFrozen: true,
        bytes: bytes,
        previewFile: file,
        capturedAt: DateTime.now(),
      );
    } catch (_) {}
  }

  Future<void> switchCamera() async {
    final ps = _photoState;
    if (ps == null) return;
    await ps.switchCameraSensor();

    _sensorPosition = _sensorPosition == SensorPosition.back
        ? SensorPosition.front
        : SensorPosition.back;
  }

  void send() {
    if (state.isSending) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (state.bytes == null && state.frozenImage == null) return;

    state = state.copyWith(isSending: true);

    // Prepare temp data immediately for smooth navigation
    final tempBytes = state.bytes ?? Uint8List(0);
    ref
        .read(temporaryCapturedImageProvider.notifier)
        .setImage(
          TemporaryCapturedImage(
            bytes: tempBytes,
            caption: captionController.text.trim().isEmpty
                ? null
                : captionController.text.trim(),
            capturedAt: state.capturedAt ?? DateTime.now(),
            sensorRotation: state.sensorRotation,
            sensorPosition: state.sensorPosition,
          ),
        );

    _uploadWithOrientedUpdate();
  }

  Future<void> _uploadWithOrientedUpdate() async {
    if (state.frozenImage != null && state.bytes == null) {
      final oriented = await _generateOrientedBytes();
      if (oriented != null) {
        final currentTemp = ref.read(temporaryCapturedImageProvider);
        if (currentTemp != null) {
          ref
              .read(temporaryCapturedImageProvider.notifier)
              .setImage(
                TemporaryCapturedImage(
                  bytes: oriented,
                  caption: currentTemp.caption,
                  capturedAt: currentTemp.capturedAt,
                ),
              );
        }
      }
    }
    await _uploadInBackground();
  }

  Future<void> _uploadInBackground() async {
    try {
      File? fileToUpload;

      if (state.previewFile != null) {
        final originalFile = state.previewFile!;
        final processedFile = await _processFileForUpload(originalFile);
        fileToUpload = processedFile ?? originalFile;
      } else {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final tempFile = File('${tempDir.path}/pet_live_$timestamp.png');

        if (state.bytes != null) {
          await tempFile.writeAsBytes(state.bytes!);
        } else if (state.frozenImage != null) {
          final png = await state.frozenImage!.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (png != null)
            await tempFile.writeAsBytes(png.buffer.asUint8List());
        }

        if (tempFile.existsSync()) {
          final processedFile = await _processFileForUpload(tempFile);
          fileToUpload = processedFile ?? tempFile;
        }
      }

      if (fileToUpload == null) return;

      final cloudinaryService = ref.read(cloudinaryUploadServiceProvider);
      final sendImageUseCase = ref.read(sendImageToPetUseCaseProvider);

      final uploadResult = await cloudinaryService.uploadImage(fileToUpload);

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
              ref.read(petAlbumNotifierProvider.notifier).refresh();
              ref.read(streakNotifierProvider.notifier).fetchStreak();
              state = state.copyWith(isSending: false);
            },
            error: (_) {
              state = state.copyWith(isSending: false);
            },
          );
        },
        error: (_) {
          state = state.copyWith(isSending: false);
        },
      );
    } catch (_) {
      state = state.copyWith(isSending: false);
    }
  }

  Future<void> toggleFlash() async {
    final ps = _photoState;
    if (ps == null) return;

    FlashMode next;
    switch (state.flashMode) {
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

    await ps.sensorConfig.setFlashMode(next);
    state = state.copyWith(flashMode: next);
  }

  Future<Uint8List?> _generateOrientedBytes() async {
    final uiImage = state.frozenImage;
    if (uiImage == null) return state.bytes;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final bool isRotated =
        state.sensorRotation == 90 || state.sensorRotation == 270;
    final outW = isRotated ? uiImage.height : uiImage.width;
    final outH = isRotated ? uiImage.width : uiImage.height;

    final center = Offset(outW / 2, outH / 2);
    canvas.translate(center.dx, center.dy);

    if (state.sensorRotation != 0) {
      canvas.rotate(state.sensorRotation * 3.1415926535897932 / 180);
    }

    if (state.sensorPosition == SensorPosition.front) {
      canvas.scale(-1, 1);
    }

    canvas.drawImage(
      uiImage,
      Offset(-uiImage.width / 2, -uiImage.height / 2),
      Paint()..filterQuality = ui.FilterQuality.high,
    );

    final picture = recorder.endRecording();
    final orientedImage = await picture.toImage(outW, outH);
    final data = await orientedImage.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  String? _extractPath(CaptureRequest request) {
    return request.when(
      single: (s) => s.file?.path,
      multiple: (m) => m.fileBySensor.values.first?.path,
    );
  }

  img.Image _cropCenter(img.Image src, double aspect) {
    final srcAspect = src.width / src.height;

    int w, h;
    if (srcAspect > aspect) {
      h = src.height;
      w = (h * aspect).round();
    } else {
      w = src.width;
      h = (w / aspect).round();
    }

    final x = (src.width - w) ~/ 2;
    final y = (src.height - h) ~/ 2;
    return img.copyCrop(src, x: x, y: y, width: w, height: h);
  }

  Future<ui.Image> _convertAnalysisImage(AnalysisImage image) async {
    if (image is Nv21Image) {
      final width = image.width;
      final height = image.height;

      final receivePort = ReceivePort();
      await Isolate.spawn(ImageProcessUtils.convertNV21ToRGBA, {
        'bytes': image.bytes,
        'width': width,
        'height': height,
        'sendPort': receivePort.sendPort,
      });

      final rgbaBytes = await receivePort.first as Uint8List;

      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        rgbaBytes,
        width,
        height,
        ui.PixelFormat.rgba8888,
        (ui.Image result) => completer.complete(result),
      );
      return completer.future;
    } else if (image is Bgra8888Image) {
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        image.bytes,
        image.width,
        image.height,
        ui.PixelFormat.bgra8888,
        (ui.Image result) => completer.complete(result),
      );
      return completer.future;
    }

    throw Exception('Unsupported image format');
  }
}
