import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';

import 'pet_capture_state.dart';

class PetCaptureNotifier extends Notifier<PetCaptureState> {
  PhotoCameraState? _photoState;
  final captionController = TextEditingController();
  bool _isCapturingInProgress = false;
  AnalysisImage? _latestFrame;

  // 🔥 Sensor orientation để fix rotation
  SensorPosition _sensorPosition = SensorPosition.back;
  int _sensorRotation = 0;
  double _currentZoom = 1.0; // 🔥 Zoom hiện tại của camera

  static const double _previewAspectRatio =
      4 / 3.9; // 🔥 Khớp với CaptureLayoutMetrics (4/3.9)

  @override
  PetCaptureState build() {
    return const PetCaptureState();
  }

  // ===== Attach camera =====
  void attachState(CameraState cameraState) {
    cameraState.when(
      onPhotoMode: (photoState) {
        _photoState = photoState;
        final newFlash = photoState.sensorConfig.flashMode;
        if (state.flashMode != newFlash) {
          state = state.copyWith(
            flashMode: newFlash,
            sensorPosition: photoState.sensorConfig.sensors.first.position,
          );
        }

        // 🔥 LẤY ZOOM TỪ CAMERA (QUAN TRỌNG - Preview có zoom nội bộ)
        _updateZoomFromCamera();

        // 🔥 Rotation sẽ được lấy từ AnalysisImage trong onLiveFrame
        // Không cần set ở đây vì sẽ được update từ frame đầu tiên
        _sensorPosition = SensorPosition.back;

        debugPrint(
          'Camera attached: rotation=$_sensorRotation position=$_sensorPosition zoom=$_currentZoom',
        );
      },
    );
  }

  // ===== Update zoom từ camera state =====
  void _updateZoomFromCamera() {
    final ps = _photoState;
    if (ps == null) return;

    try {
      _currentZoom = ps.sensorConfig.zoom;
    } catch (_) {
      _currentZoom = 1.0; // Fallback nếu không có zoom
    }
  }

  // ===== Helper: Convert InputAnalysisImageRotation → int =====
  int _rotationToDegrees(dynamic rotation) {
    // InputAnalysisImageRotation là enum, convert sang int
    final rotationStr = rotation.toString();
    if (rotationStr.contains('90')) return 90;
    if (rotationStr.contains('180')) return 180;
    if (rotationStr.contains('270')) return 270;
    return 0; // rotation0deg hoặc default
  }

  // ===== Cache live frame (KHÔNG setState) =====
  void onLiveFrame(AnalysisImage image) {
    // 🔥 chỉ cache, KHÔNG setState
    _latestFrame = image;

    // 🔥 LẤY ROTATION TỪ AnalysisImage (QUAN TRỌNG)
    image.when(
      nv21: (nv21) {
        _sensorRotation = _rotationToDegrees(
          nv21.rotation,
        ); // ✅ Lấy rotation thực từ camera
      },
      bgra8888: (bgra) {
        _sensorRotation = _rotationToDegrees(
          bgra.rotation,
        ); // ✅ Lấy rotation thực từ camera
      },
    );
  }

  // ===== Freeze from live frame (LOCKET STYLE - 0ms delay) =====
  Future<void> freezeFromLiveFrame() async {
    if (state.isFrozen || _latestFrame == null) return;

    state = state.copyWith(isCapturing: true);

    try {
      _updateZoomFromCamera();
      final uiImage = await _convertAnalysisImage(_latestFrame!);

      // 🔥 Freeze LẬP TỨC: Không encode PNG/JPG, dùng luôn ui.Image
      state = state.copyWith(
        isFrozen: true,
        frozenImage: uiImage,
        isCapturing: false,
        capturedAt: DateTime.now(),
        sensorRotation: _sensorRotation,
        sensorPosition: _sensorPosition,
      );

      // Lưu bytes ngầm (PNG để hiển thị được trong MemoryImage) cho swipe screen
      uiImage.toByteData(format: ui.ImageByteFormat.png).then((data) {
        if (data != null) {
          state = state.copyWith(bytes: data.buffer.asUint8List());
        }
      });
    } catch (e) {
      state = state.copyWith(isCapturing: false);
    }
  }

  // ===== Capture (LOCKET STYLE - OPTIMIZED) =====
  Future<void> capturePhoto() async {
    // 🔥 Chặn nếu đang chụp, đang gửi, đã freeze rồi
    if (state.isCapturing ||
        state.isSending ||
        state.isFrozen ||
        _isCapturingInProgress) {
      return;
    }

    final ps = _photoState;
    if (ps == null) return;

    // 🔥 BƯỚC 1: Set flag để chặn gọi lại
    _isCapturingInProgress = true;
    state = state.copyWith(isCapturing: true);

    try {
      // 🔥 BƯỚC 2: Chụp ảnh (async, không đợi file write xong)
      final request = await ps.takePhoto();
      final path = _extractPath(request);

      if (path == null) {
        state = state.copyWith(isCapturing: false);
        return;
      }

      final file = File(path);

      // 🔥 BƯỚC 3: Đọc bytes NGAY để preview (chỉ cần bytes, không process)
      final bytes = await file.readAsBytes();

      // 🔥 BƯỚC 4: Freeze ngay lập tức (1 bước duy nhất)
      state = state.copyWith(
        isFrozen: true, // ✅ Freeze flag
        bytes: bytes, // ✅ Preview từ RAM
        previewFile: file, // ✅ Lưu file gốc tạm thời (chưa process)
        capturedAt: DateTime.now(), // ✅ Giữ lại cho send API
        isCapturing: false,
      );

      // ❌ KHÔNG process file ở đây - sẽ làm khi send
    } catch (e) {
      state = state.copyWith(isCapturing: false);
    } finally {
      _isCapturingInProgress = false;
    }
  }

  /// Process file CHỈ KHI send (thay vì process ngay khi capture)
  Future<File?> _processFileForUpload(File originalFile) async {
    try {
      // Đọc bytes từ file gốc
      final originalBytes = await originalFile.readAsBytes();
      var image = img.decodeImage(originalBytes);
      if (image == null) return null;

      // 🔥 Áp dụng rotation và mirror từ cảm biến
      if (state.sensorRotation != 0) {
        image = img.copyRotate(image, angle: state.sensorRotation);
      }
      if (state.sensorPosition == SensorPosition.front) {
        image = img.flipHorizontal(image);
      }

      // 🔥 Crop ảnh
      var processed = _cropCenter(image, _previewAspectRatio);

      // 🔥 Resize để đảm bảo kích thước tối thiểu (giữ tỷ lệ)
      // Đảm bảo chiều dài nhất >= 1280px
      const int minLongestSide = 1280;
      final longestSide = processed.width > processed.height
          ? processed.width
          : processed.height;

      int targetWidth = processed.width;
      int targetHeight = processed.height;

      if (longestSide < minLongestSide) {
        // Tính scale factor để resize
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

      // 🔥 Lưu ảnh đã crop và resize vào temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final tempProcessedFile = File(
        '${tempDir.path}/pet_processed_$timestamp.jpg',
      );
      final encoded = img.encodeJpg(processed, quality: 90);
      await tempProcessedFile.writeAsBytes(encoded);

      // 🔥 Dùng flutter_image_compress để xóa EXIF metadata và đảm bảo kích thước
      // keepExif: false → Xóa Location/GPS metadata
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        tempProcessedFile.absolute.path,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: 90,
        keepExif: false, // 🔥 QUAN TRỌNG: Xóa EXIF metadata (Location)
      );

      if (compressedBytes == null) {
        // Fallback: dùng file đã process nếu compress fail
        return tempProcessedFile;
      }

      // 🔥 Lưu file cuối cùng (đã xóa EXIF)
      final finalFile = File('${tempDir.path}/pet_$timestamp.jpg');
      await finalFile.writeAsBytes(compressedBytes);

      // Xóa temp file
      try {
        await tempProcessedFile.delete();
      } catch (_) {
        // Ignore delete error
      }

      return finalFile;
    } catch (_) {
      // Nếu process fail, return null để dùng file gốc
      return null;
    }
  }

  // ===== Reset (❌) =====
  void resetPreview() {
    captionController.clear();
    _isCapturingInProgress = false;
    _latestFrame = null; // Clear cached frame
    // 🔥 Clear bytes để tránh leak RAM
    state = state.copyWith(
      isFrozen: false,
      clearBytes: true,
      previewFile: null,
      capturedAt: null,
    );
  }

  // ===== Set preview from gallery =====
  Future<void> setPreviewFile(File file) async {
    try {
      // 🔥 Đọc bytes ngay cho preview
      final bytes = await file.readAsBytes();
      state = state.copyWith(
        isFrozen: true, // ✅ Freeze ngay
        bytes: bytes,
        previewFile: file, // ✅ Lưu file gốc (chưa process)
        capturedAt: DateTime.now(),
      );

      // ❌ KHÔNG process file ở đây - sẽ làm khi send
    } catch (_) {
      // Ignore error
    }
  }

  // ===== Switch camera =====
  Future<void> switchCamera() async {
    final ps = _photoState;
    if (ps == null) return;
    await ps.switchCameraSensor();

    // 🔥 Update sensor position khi switch
    _sensorPosition = _sensorPosition == SensorPosition.back
        ? SensorPosition.front
        : SensorPosition.back;
    // Rotation sẽ được update từ camera state
  }

  // ===== Send =====
  void send() {
    if (state.isSending) return;

    // 🔥 1. Tắt bàn phím ngay lập tức để giải phóng UI thread
    FocusManager.instance.primaryFocus?.unfocus();

    if (state.bytes == null) return;

    // 🔥 2. Kích hoạt chuyển trang NGAY LẬP TỨC qua listener
    state = state.copyWith(isSending: true);

    // 🔥 3. Set temporary image để màn hình album có data ngay
    ref
        .read(temporaryCapturedImageProvider.notifier)
        .setImage(
          TemporaryCapturedImage(
            bytes: state.bytes!,
            caption: captionController.text.trim().isEmpty
                ? null
                : captionController.text.trim(),
            capturedAt: state.capturedAt ?? DateTime.now(),
            sensorRotation: state.sensorRotation,
            sensorPosition: state.sensorPosition,
          ),
        );

    // 🔥 4. Chạy các tác vụ nặng ngầm (Xoay ảnh + Upload) - sau khi đã ra lệnh chuyển trang
    _uploadWithOrientedUpdate();
  }

  // Chạy background xử lý orient và upload
  Future<void> _uploadWithOrientedUpdate() async {
    // Xoay ảnh local chuẩn hóa lại (ngầm)
    final oriented = await _generateOrientedBytes();
    if (oriented != null) {
      // Cập nhật lại temporary image với bản đã xoay đẹp hơn
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
    // Tiến hành upload như cũ
    await _uploadInBackground();
  }

  // ===== Upload ngầm (background) =====
  Future<void> _uploadInBackground() async {
    try {
      File? fileToUpload;

      if (state.previewFile != null) {
        // 🔥 Case: freeze từ capture photo hoặc gallery
        final originalFile = state.previewFile!;
        final processedFile = await _processFileForUpload(originalFile);
        fileToUpload = processedFile ?? originalFile;
      } else {
        // 🔥 Case: freeze từ live frame - tạo file từ bytes hoặc frozenImage
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

        // Process file (crop + encode to JPG)
        final processedFile = await _processFileForUpload(tempFile);
        fileToUpload = processedFile ?? tempFile;
      }

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
              // 🔥 Upload thành công - KHÔNG clear temporary image
              // Temporary image sẽ LUÔN hiển thị ở vị trí đầu tiên
              // Chỉ refresh album để cập nhật danh sách (để lấy EXP từ server)
              ref.read(petAlbumNotifierProvider.notifier).refresh();
              // 🔥 Set isSending = false sau khi upload xong
              state = state.copyWith(isSending: false);
            },
            error: (_) {
              // 🔥 Upload lỗi - vẫn giữ temporary image để user thấy
              // Có thể thêm retry logic sau
              state = state.copyWith(isSending: false);
            },
          );
        },
        error: (_) {
          // 🔥 Upload lỗi - vẫn giữ temporary image
          state = state.copyWith(isSending: false);
        },
      );
    } catch (_) {
      // 🔥 Upload lỗi - vẫn giữ temporary image
      state = state.copyWith(isSending: false);
    }
  }

  // ===== Flash =====
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

  // ===== Helpers =====
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

  // ===== Convert AnalysisImage → ui.Image =====
  Future<ui.Image> _convertAnalysisImage(AnalysisImage image) async {
    final result = await image.when(
      nv21: (nv21) async {
        final width = nv21.width;
        final height = nv21.height;

        // 1️⃣ Convert NV21 → RGBA bytes ngay lập tức (hiếm khi khựng vì là loop đơn giản)
        final rgbaBytes = Uint8List(width * height * 4);
        _convertNV21ToRGBA(nv21.bytes, width, height, rgbaBytes);

        // 2️⃣ Dùng decodeImageFromPixels cho tốc độ (gần như 0ms)
        final completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(
          rgbaBytes,
          width,
          height,
          ui.PixelFormat.rgba8888,
          (ui.Image image) => completer.complete(image),
        );
        return completer.future;
      },
      bgra8888: (bgra) async {
        // BGRA → RGBA chỉ là đổi vị trí R và B
        final rgbaBytes = Uint8List(bgra.bytes.length);
        for (int i = 0; i < bgra.bytes.length; i += 4) {
          rgbaBytes[i] = bgra.bytes[i + 2]; // R
          rgbaBytes[i + 1] = bgra.bytes[i + 1]; // G
          rgbaBytes[i + 2] = bgra.bytes[i]; // B
          rgbaBytes[i + 3] = bgra.bytes[i + 3]; // A
        }

        final completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(
          rgbaBytes,
          bgra.width,
          bgra.height,
          ui.PixelFormat.rgba8888,
          (ui.Image image) => completer.complete(image),
        );
        return completer.future;
      },
    );

    return result ?? (throw Exception('Failed to convert AnalysisImage'));
  }

  // ===== Manual NV21 → RGBA conversion (SIÊU NHANH) =====
  void _convertNV21ToRGBA(
    Uint8List nv21Bytes,
    int width,
    int height,
    Uint8List rgbaBytes,
  ) {
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
  }

  // orientation and zoom calculations are now handled in the CustomPainter for maximum speed
}
