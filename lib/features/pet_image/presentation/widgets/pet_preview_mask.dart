import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/models/capture_layout_metrics.dart';

/// Widget mask overlay - dùng metrics chung, không tự tính toán
class PetPreviewMask extends StatelessWidget {
  const PetPreviewMask({required this.metrics, super.key});

  final CaptureLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    // 🔥 Dùng metrics chung - không tính lại
    return Positioned.fill(
      child: CustomPaint(
        painter: PreviewMaskPainter(containerRect: metrics.previewRRect),
      ),
    );
  }
}

class PreviewMaskPainter extends CustomPainter {
  PreviewMaskPainter({required this.containerRect});

  final RRect containerRect;

  @override
  void paint(Canvas canvas, Size size) {
    final maskPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(containerRect)
      ..fillType = PathFillType.evenOdd;

    // Vẽ gradient background thay vì màu đen
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColors.backgroundGradient,
    );
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(maskPath, paint);
  }

  @override
  bool shouldRepaint(PreviewMaskPainter oldDelegate) {
    return oldDelegate.containerRect != containerRect;
  }
}
