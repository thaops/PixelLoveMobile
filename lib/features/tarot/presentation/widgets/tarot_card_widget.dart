import 'dart:math';
import 'package:flutter/material.dart';

class TarotCardWidget extends StatefulWidget {
  final int id;
  final bool isRevealed;
  final bool isGlow;
  final bool isSelected;
  final VoidCallback? onTap;
  final double scale;

  const TarotCardWidget({
    super.key,
    required this.id,
    this.isRevealed = false,
    this.isGlow = false,
    this.isSelected = false,
    this.onTap,
    this.scale = 1.0,
  });

  @override
  State<TarotCardWidget> createState() => _TarotCardWidgetState();
}

class _TarotCardWidgetState extends State<TarotCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.isRevealed ? 0 : _floatAnimation.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: widget.isSelected ? 1.05 : widget.scale,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: AnimatedRotation(
            turns: widget.isSelected ? 0.01 : 0,
            duration: const Duration(milliseconds: 300),
            child: _buildCardContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Container(
      width: 140,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: widget.isGlow
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotateAngle = Tween<double>(
                begin: pi,
                end: 0,
              ).animate(animation);
              return AnimatedBuilder(
                animation: rotateAngle,
                builder: (context, child) {
                  final isUnder = (ValueKey(widget.isRevealed) != child!.key);
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(rotateAngle.value),
                    alignment: Alignment.center,
                    child: isUnder
                        ? const SizedBox.shrink()
                        : Transform(
                            transform: Matrix4.identity()
                              ..rotateY(rotateAngle.value > pi / 2 ? pi : 0),
                            alignment: Alignment.center,
                            child: child,
                          ),
                  );
                },
                child: child,
              );
            },
            child: widget.isRevealed
                ? _buildFront(key: const ValueKey(true))
                : _buildBack(key: const ValueKey(false)),
          ),
          if (widget.isGlow)
            Positioned.fill(
              child: _GlowBorder(color: Colors.amber.withOpacity(0.6)),
            ),
        ],
      ),
    );
  }

  Widget _buildFront({required Key key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2D42), Color(0xFF1A1B2E)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: _CardPatternPainter()),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: Color(0xFFFFD700),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'CARD ${widget.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBack({required Key key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/img_tarot.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _GlowBorder extends StatefulWidget {
  final Color color;
  const _GlowBorder({required this.color});

  @override
  State<_GlowBorder> createState() => _GlowBorderState();
}

class _GlowBorderState extends State<_GlowBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withOpacity(0.3 + 0.5 * _controller.value),
              width: 2 + 2 * _controller.value,
            ),
          ),
        );
      },
    );
  }
}
