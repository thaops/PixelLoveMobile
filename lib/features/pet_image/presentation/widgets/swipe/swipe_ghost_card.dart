import 'package:flutter/material.dart';

class SwipeGhostCard extends StatelessWidget {
  final double cardWidth;
  final double cardHeight;
  final bool isLoading;

  const SwipeGhostCard({
    super.key,
    required this.cardWidth,
    required this.cardHeight,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      width: cardWidth,
      height: cardHeight,
      constraints: BoxConstraints(maxWidth: cardWidth, maxHeight: cardHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44),
        color: Colors.black.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '🕰️ Đang đào ký ức cũ hơn...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ] else ...[
              Icon(Icons.pets, size: 48, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                '🐾 Đang tìm thêm...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
