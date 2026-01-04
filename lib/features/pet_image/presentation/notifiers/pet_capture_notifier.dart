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
          state = state.copyWith(flashMode: newFlash);
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
      // 🔥 CẬP NHẬT ZOOM TỪ CAMERA STATE (đảm bảo luôn đúng)
      _updateZoomFromCamera();

      // 🔥 Convert AnalysisImage → ui.Image
      final uiImage = await _convertAnalysisImage(_latestFrame!);

      // 🔥 Vẽ ui.Image → bytes (PNG, không crop)
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // 🔥 Freeze ngay lập tức - không I/O, không delay
      state = state.copyWith(
        isFrozen: true,
        bytes: bytes,
        isCapturing: false,
        capturedAt: DateTime.now(),
        // ❌ KHÔNG set previewFile ở đây - sẽ tạo khi send
      );
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
  Future<void> send() async {
    if (state.isSending) return;
    if (state.bytes == null) return; // 🔥 Cần có bytes để send

    state = state.copyWith(isSending: true);
    try {
      File? fileToUpload;

      if (state.previewFile != null) {
        // 🔥 Case: freeze từ capture photo hoặc gallery
        final originalFile = state.previewFile!;
        final processedFile = await _processFileForUpload(originalFile);
        fileToUpload = processedFile ?? originalFile;
      } else {
        // 🔥 Case: freeze từ live frame - tạo file từ bytes
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final tempFile = File('${tempDir.path}/pet_live_$timestamp.png');
        await tempFile.writeAsBytes(state.bytes!);

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
              resetPreview();
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

        // 🔥 Debug log
        debugPrint(
          'NV21 frame: ${width}x${height}, bytes=${nv21.bytes.length}',
        );

        // 1️⃣ Convert NV21 → RGB image (image package)
        var rgbImage = img.Image(width: width, height: height);

        // 🔥 BƯỚC SỐNG CÒN: Manual NV21 → RGB conversion
        _convertNV21ToRGB(nv21.bytes, width, height, rgbImage);

        // 🔥 FIX ORIENTATION - Rotate + flip để khớp preview
        rgbImage = _applyOrientation(
          rgbImage,
          _sensorRotation,
          _sensorPosition,
        );

        // 🔥 BÙ ZOOM CHO GIỐNG PREVIEW (SAU rotate)
        rgbImage = _applyZoom(rgbImage, _currentZoom);

        // 2️⃣ Encode RGB → PNG
        final pngBytes = img.encodePng(rgbImage);

        // 3️⃣ Decode PNG → ui.Image
        final codec = await ui.instantiateImageCodec(pngBytes);
        final frame = await codec.getNextFrame();

        return frame.image;
      },
      bgra8888: (bgra) async {
        // 🔥 Decode BGRA → RGB image để apply orientation
        var rgbImage = img.Image(width: bgra.width, height: bgra.height);

        // Convert BGRA → RGB
        for (int y = 0; y < bgra.height; y++) {
          for (int x = 0; x < bgra.width; x++) {
            final index = (y * bgra.width + x) * 4;
            if (index + 3 >= bgra.bytes.length) continue;

            final b = bgra.bytes[index];
            final g = bgra.bytes[index + 1];
            final r = bgra.bytes[index + 2];
            // index + 3 là alpha, bỏ qua

            rgbImage.setPixelRgb(x, y, r, g, b);
          }
        }

        // 🔥 FIX ORIENTATION - Rotate + flip để khớp preview
        rgbImage = _applyOrientation(
          rgbImage,
          _rotationToDegrees(
            bgra.rotation,
          ), // ✅ Dùng rotation từ bgra (convert sang int)
          _sensorPosition,
        );

        // 🔥 BÙ ZOOM CHO GIỐNG PREVIEW (SAU rotate)
        rgbImage = _applyZoom(rgbImage, _currentZoom);

        // Encode RGB → PNG
        final pngBytes = img.encodePng(rgbImage);

        // Decode PNG → ui.Image
        final codec = await ui.instantiateImageCodec(pngBytes);
        final frame = await codec.getNextFrame();
        return frame.image;
      },
    );

    return result ?? (throw Exception('Failed to convert AnalysisImage'));
  }

  // ===== Manual NV21 → RGB conversion =====
  void _convertNV21ToRGB(
    Uint8List nv21Bytes,
    int width,
    int height,
    img.Image rgbImage,
  ) {
    // NV21 format: Y plane (width * height) + interleaved VU plane (width * height / 2)
    final ySize = width * height;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Get Y (luminance)
        final yIndex = y * width + x;
        if (yIndex >= nv21Bytes.length) continue;
        final yValue = nv21Bytes[yIndex];

        // Get UV (chrominance) - NV21 is interleaved VU
        final uvIndex = ySize + ((y ~/ 2) * width) + (x ~/ 2) * 2;
        final vValue = uvIndex < nv21Bytes.length ? nv21Bytes[uvIndex] : 128;
        final uValue = uvIndex + 1 < nv21Bytes.length
            ? nv21Bytes[uvIndex + 1]
            : 128;

        // Convert YUV to RGB
        final r = _yuvToR(yValue, uValue, vValue);
        final g = _yuvToG(yValue, uValue, vValue);
        final b = _yuvToB(yValue, uValue, vValue);

        rgbImage.setPixelRgb(x, y, r, g, b);
      }
    }
  }

  int _yuvToR(int y, int u, int v) {
    final r = (y + 1.402 * (v - 128)).round();
    return r.clamp(0, 255);
  }

  int _yuvToG(int y, int u, int v) {
    final g = (y - 0.344 * (u - 128) - 0.714 * (v - 128)).round();
    return g.clamp(0, 255);
  }

  int _yuvToB(int y, int u, int v) {
    final b = (y + 1.772 * (u - 128)).round();
    return b.clamp(0, 255);
  }

  // ===== Apply orientation - Rotate + flip để khớp preview =====
  img.Image _applyOrientation(
    img.Image src,
    int rotation,
    SensorPosition position,
  ) {
    img.Image out = src;

    // ✅ Rotate theo rotation THỰC từ camera (KHÔNG xoay ngược)
    switch (rotation) {
      case 90:
        out = img.copyRotate(out, angle: 90);
        break;
      case 180:
        out = img.copyRotate(out, angle: 180);
        break;
      case 270:
        out = img.copyRotate(out, angle: 270);
        break;
      // case 0: không cần rotate
    }

    // ✅ Mirror chỉ khi camera trước
    if (position == SensorPosition.front) {
      out = img.flipHorizontal(out);
    }

    return out;
  }

  // ===== Apply zoom - Crop center để khớp preview zoom =====
  img.Image _applyZoom(img.Image src, double zoom) {
    // 🔥 (A) Bù nhẹ khi zoom = 1.0 (CameraAwesome có internal scale ~1.03-1.08x)
    // Preview thực tế có thể là 1.05x nhưng _currentZoom = 1.0
    // Empiric value, test trên Pixel (Instagram cũng làm kiểu "empiric fudge factor" này)
    final effectiveZoom = zoom <= 1.01 ? 1.05 : zoom;

    // 🔥 Crop center: giảm kích thước theo zoom
    final newWidth = (src.width / effectiveZoom).round();
    final newHeight = (src.height / effectiveZoom).round();

    final x = (src.width - newWidth) ~/ 2;

    // 🔥 (B) Dịch crop Y lên nhẹ theo previewAlignment (0, -0.37)
    // Preview bị dịch lên trên → cảm giác zoom hơn → dịch crop Y lên để khớp cảm giác thị giác
    final yOffset = (src.height * 0.05)
        .round(); // ~5% height, tương ứng với -0.37 alignment
    final y = ((src.height - newHeight) ~/ 2) - yOffset;

    // 🔥 Clamp Y để không vượt quá bounds
    final clampedY = y.clamp(0, src.height - newHeight);

    return img.copyCrop(
      src,
      x: x,
      y: clampedY,
      width: newWidth,
      height: newHeight,
    );
  }
}
