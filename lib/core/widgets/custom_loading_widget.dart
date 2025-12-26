import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class CustomLoadingWidget extends StatefulWidget {
  final String avatarPath;
  final double size;
  final Color color;
  final Duration duration;

  const CustomLoadingWidget({
    super.key,
    this.avatarPath = 'assets/images/avata-female.png',
    this.size = 120,
    this.color = AppColors.primaryPink,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = widget.size * 0.6;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// 🔄 Thin rotating arc
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ArcPainter(color: widget.color.withOpacity(0.85)),
                ),
              );
            },
          ),

          /// 👤 Avatar
          ClipOval(
            child: Image.asset(
              widget.avatarPath,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 Arc Painter (mảnh – hiện đại)
class _ArcPainter extends CustomPainter {
  final Color color;

  _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 4.5;
    final radius = size.width / 2 - strokeWidth;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Chỉ vẽ 1 đoạn arc (~70°)
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      -pi / 2,
      pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
