import 'dart:math';
import 'package:flutter/material.dart';

class SwipeReactionParticleOverlay extends StatefulWidget {
  final ReactionParticleController controller;

  const SwipeReactionParticleOverlay({super.key, required this.controller});

  @override
  State<SwipeReactionParticleOverlay> createState() =>
      _SwipeReactionParticleOverlayState();
}

class _SwipeReactionParticleOverlayState
    extends State<SwipeReactionParticleOverlay>
    with TickerProviderStateMixin {
  final List<_Particle> _particles = [];
  final Random _random = Random();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateParticles);

    widget.controller._attach(this);
  }

  @override
  void dispose() {
    widget.controller._detach();
    _animationController.dispose();
    super.dispose();
  }

  void emit(String emoji, {required Offset position}) {
    if (_particles.isEmpty && !_animationController.isAnimating) {
      _animationController.repeat();
    }

    // Chặn chống spam, nếu còn đang có trên 60 icon rơi thì vứt bớt icon cũ đi để khỏi lỗi lag drop Frame Rate GPU
    if (_particles.length > 50) {
      _particles.removeRange(0, _particles.length - 50);
    }

    // Tối ưu số lượng rơi: Nổ càng nhiều thì mật độ của vụ nổ tiếp theo càng ít đi. Cân bằng trải nghiệm và hiệu suất
    int spawnAmount = 15; // Mặc định nhiều nhất (Thả tym ít)
    if (_particles.length > 30) {
      spawnAmount = 6; // Đang spam trên 30 cái rơi, cho nổ 6 cái mỗi nhấp
    }
    if (_particles.length > 45) {
      spawnAmount =
          2; // Rất kịch liệt spam, chỉ cho 2 cái nhú lên để tối ưu lag
    }

    for (int i = 0; i < spawnAmount; i++) {
      _particles.add(
        _Particle(
          emoji: emoji,
          // Bắt đầu từ vị trí của ngón tay
          x: position.dx - 15,
          // Bắt đầu cao hơn rất nhiều để thoát khỏi vị trí ngón tay và vút lên trên màn
          y: position.dy - 160,
          // Toả ra 2 bên hình phễu cực rộng
          vx: (_random.nextDouble() - 0.5) * 35,
          // Bắn vút cao lên tít trên cùng (giá trị âm càng lớn càng bắn cao)
          vy: -28 - (_random.nextDouble() * 22),
          life: 1.0,
          rotation: _random.nextDouble() * pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.4,
          size: 22 + _random.nextDouble() * 26,
        ),
      );
    }
  }

  void _updateParticles() {
    if (_particles.isEmpty) {
      _animationController.stop();
      return;
    }

    final size = MediaQuery.of(context).size;

    setState(() {
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];

        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.9; // Lực hút trái đất nhẹ vừa, kéo nó rơi từ từ
        p.rotation += p.rotationSpeed;
        p.life -= 0.009; // Lâu mờ hơn, tồn tại trên không trung lâu hơn

        if (p.life <= 0 ||
            p.y > size.height + 50 ||
            p.x < -100 ||
            p.x > size.width + 100) {
          _particles.removeAt(i);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _particles.map((p) {
          return Positioned(
            left: p.x,
            top: p.y,
            child: Opacity(
              opacity: p.life.clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: p.rotation,
                child: Text(p.emoji, style: TextStyle(fontSize: p.size)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Particle {
  final String emoji;
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double rotation;
  double rotationSpeed;
  double size;

  _Particle({
    required this.emoji,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });
}

class ReactionParticleController {
  _SwipeReactionParticleOverlayState? _state;

  void _attach(_SwipeReactionParticleOverlayState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  void emit(String emoji, {required Offset position}) {
    _state?.emit(emoji, position: position);
  }
}
