import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';

class PetPreviewMask extends ConsumerWidget {
  const PetPreviewMask({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth * 0.92;
    // Đổi từ 4/3.5 về 4/3 để khớp với sensor ratio_4_3
    final containerHeight = containerWidth * 4 / 3.5;
    final containerLeft = (screenWidth - containerWidth) / 2;

    final captureState = ref.watch(petCaptureNotifierProvider);
    final headerHeight = captureState.isPreviewMode ? 0.0 : 50.0;
    final footerHeight = captureState.isPreviewMode ? 0.0 : 00.0;
    final actionBarHeight = 190.0;
    final cameraPaddingBottom = 62.0;

    final availableHeight =
        screenHeight - headerHeight - actionBarHeight - footerHeight;
    // Giảm offset để khung mask nằm cao hơn một chút
    final offsetUp = 20.0;
    final containerTop =
        headerHeight +
        (availableHeight - containerHeight - cameraPaddingBottom) / 2 -
        offsetUp;

    return Positioned.fill(
      child: CustomPaint(
        painter: PreviewMaskPainter(
          containerRect: RRect.fromRectAndRadius(
            Rect.fromLTWH(
              containerLeft,
              containerTop,
              containerWidth,
              containerHeight,
            ),
            const Radius.circular(44),
          ),
        ),
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

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawPath(maskPath, paint);
  }

  @override
  bool shouldRepaint(PreviewMaskPainter oldDelegate) {
    return oldDelegate.containerRect != containerRect;
  }
}
