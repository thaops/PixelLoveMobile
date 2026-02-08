import 'package:flutter/material.dart';

class SwipeSkeletonCard extends StatelessWidget {
  final double cardWidth;
  final double cardHeight;
  final Animation<double> shimmerAnimation;

  const SwipeSkeletonCard({
    super.key,
    required this.cardWidth,
    required this.cardHeight,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: cardWidth,
        height: cardHeight,
        constraints: BoxConstraints(maxWidth: cardWidth, maxHeight: cardHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(44),
          color: Colors.white.withOpacity(0.1),
        ),
        child: AnimatedBuilder(
          animation: shimmerAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + shimmerAnimation.value * 2, 0),
                  end: Alignment(1.0 + shimmerAnimation.value * 2, 0),
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
