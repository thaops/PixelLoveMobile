import 'package:flutter/material.dart';

/// Layout metrics - source of truth duy nhất cho tất cả layout
/// Đảm bảo khung ảnh và UI không bị lệch khi freeze
class CaptureLayoutMetrics {
  CaptureLayoutMetrics(BuildContext context) {
    final size = MediaQuery.of(context).size;

    previewWidth = size.width * 0.94;
    previewHeight = previewWidth; // 🔥 1:1 để khớp hoàn toàn với Sensor ratio
    previewLeft = (size.width - previewWidth) / 2;

    headerHeight = 0.0; // 🔥 Luôn 0, không đổi khi freeze
    actionBarHeight = 190.0;
    cameraPaddingBottom = 62.0;

    final availableHeight = size.height - headerHeight - actionBarHeight;

    // 🔥 Khớp hoàn toàn với previewAlignment: Alignment(0, -0.5) và previewFit: contain
    const double alignmentY = -0.5;
    previewTop = (1 + alignmentY) / 2 * (size.height - size.width);
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
