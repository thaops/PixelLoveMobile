import 'package:flutter/material.dart';

class TarotCountdownWidget extends StatefulWidget {
  final int countdown;
  const TarotCountdownWidget({super.key, required this.countdown});

  @override
  State<TarotCountdownWidget> createState() => _TarotCountdownWidgetState();
}

class _TarotCountdownWidgetState extends State<TarotCountdownWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(TarotCountdownWidget oldWidget) {
    if (oldWidget.countdown != widget.countdown) {
      _controller.reset();
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value * (1 - _controller.value),
            child: Text(
              '${widget.countdown}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 140,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: Colors.pinkAccent, blurRadius: 30),
                  Shadow(color: Colors.white, blurRadius: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
