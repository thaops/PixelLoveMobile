import 'dart:ui';
import 'package:flutter/material.dart';

class TarotConnectionWidget extends StatefulWidget {
  final String? myAvatar;
  final String? partnerAvatar;
  final bool isReady;

  const TarotConnectionWidget({
    super.key,
    this.myAvatar,
    this.partnerAvatar,
    this.isReady = false,
  });

  @override
  State<TarotConnectionWidget> createState() => _TarotConnectionWidgetState();
}

class _TarotConnectionWidgetState extends State<TarotConnectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return RepaintBoundary(
                child: CustomPaint(
                  painter: ConnectionLinePainter(
                    progress: _controller.value,
                    isReady: widget.isReady,
                  ),
                  size: const Size(double.infinity, 100),
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAvatar(
                widget.myAvatar,
                'Bạn',
                'assets/images/avata-male.png',
              ),
              const SizedBox(width: 100), // Space for the line
              _buildAvatar(
                widget.partnerAvatar,
                'Người ấy',
                'assets/images/avata-female.png',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url, String label, String defaultAsset) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isReady
                  ? Colors.pinkAccent
                  : Colors.amber.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isReady ? Colors.pinkAccent : Colors.amber)
                    .withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: url != null && url.isNotEmpty
                ? NetworkImage(url)
                : AssetImage(defaultAsset) as ImageProvider,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConnectionLinePainter extends CustomPainter {
  final double progress;
  final bool isReady;

  ConnectionLinePainter({required this.progress, required this.isReady});

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.3, size.height * 0.4);
    final end = Offset(size.width * 0.7, size.height * 0.4);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(size.width / 2, size.height * 0.1, end.dx, end.dy);

    final paint = Paint()
      ..color = isReady
          ? Colors.pinkAccent.withOpacity(0.5)
          : Colors.amber.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    final beamPaint = Paint()
      ..color = isReady ? Colors.white : Colors.amber.shade200
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

    final p1 = metric.getTangentForOffset(metric.length * progress)!.position;
    final p2 = metric.getTangentForOffset(metric.length * ((progress + 0.1) % 1.0))!.position;

    canvas.drawLine(p1, p2, beamPaint);

    if (isReady) {
      for (int i = 0; i < 3; i++) {
        final p = metric.getTangentForOffset(metric.length * ((progress + i / 3) % 1.0))!.position;
        canvas.drawCircle(p, 2, beamPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionLinePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isReady != isReady;
}
