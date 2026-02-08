import 'package:flutter/material.dart';

class SwipeReactionBar extends StatelessWidget {
  final void Function(String emoji) onReaction;

  const SwipeReactionBar({super.key, required this.onReaction});

  @override
  Widget build(BuildContext context) {
    final reactions = ['❤️', '😍', '😂', '😢'];

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.asMap().entries.map((entry) {
          final index = entry.key;
          final emoji = entry.value;
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 20),
            child: SwipeReactionButton(
              emoji: emoji,
              onTap: () => onReaction(emoji),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SwipeReactionButton extends StatefulWidget {
  final String emoji;
  final VoidCallback onTap;

  const SwipeReactionButton({
    super.key,
    required this.emoji,
    required this.onTap,
  });

  @override
  State<SwipeReactionButton> createState() => _SwipeReactionButtonState();
}

class _SwipeReactionButtonState extends State<SwipeReactionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(_isPressed ? 0.3 : 0.15),
                    Colors.white.withOpacity(_isPressed ? 0.2 : 0.08),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(widget.emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
          );
        },
      ),
    );
  }
}
