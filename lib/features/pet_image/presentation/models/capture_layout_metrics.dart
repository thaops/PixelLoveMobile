import 'package:flutter/material.dart';

/// Layout metrics - source of truth duy nhất cho tất cả layout
/// Đảm bảo khung ảnh và UI không bị lệch khi freeze
class CaptureLayoutMetrics {
  CaptureLayoutMetrics(BuildContext context) {
    final size = MediaQuery.of(context).size;

    previewWidth = size.width * 0.95;
    previewHeight = previewWidth * 4 / 3.9;
    previewLeft = (size.width - previewWidth) / 2;

    headerHeight = 0.0; // 🔥 Luôn 0, không đổi khi freeze
    actionBarHeight = 190.0;
    cameraPaddingBottom = 62.0;

    final availableHeight = size.height - headerHeight - actionBarHeight;

    // 🔥 Điều chỉnh vị trí khung camera xuống thấp hơn (gần giữa màn hình)
    previewTop = (size.height - previewHeight) / 2 - 100.0;
  }

  late final double previewWidth;
  late final double previewHeight;
  late final double previewLeft;
  late final double previewTop;

  late final double headerHeight;
  late final double actionBarHeight;
  late final double cameraPaddingBottom;

  RRect get previewRRect => RRect.fromRectAndRadius(
    Rect.fromLTWH(previewLeft, previewTop, previewWidth, previewHeight),
    const Radius.circular(44),
  );
}
