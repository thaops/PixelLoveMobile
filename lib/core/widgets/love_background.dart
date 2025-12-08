import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class LoveBackground extends StatelessWidget {
  final Widget child;
  final bool showDecorativeIcons;

  const LoveBackground({
    super.key,
    required this.child,
    this.showDecorativeIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.backgroundGradient,
            ),
          ),
        ),
        // Decorative Icons
        if (showDecorativeIcons) ..._buildDecorativeIcons(),
        // Content
        child,
      ],
    );
  }

  List<Widget> _buildDecorativeIcons() {
    return [
      Positioned(
        top: 80,
        right: 40,
        child: Icon(
          Icons.favorite,
          size: 60,
          color: AppColors.iconPink.withOpacity(0.3),
        ),
      ),
      Positioned(
        top: 150,
        left: 30,
        child: Icon(
          Icons.favorite_border,
          size: 45,
          color: AppColors.iconPurple.withOpacity(0.25),
        ),
      ),
      Positioned(
        top: 250,
        right: 80,
        child: Icon(
          Icons.favorite,
          size: 35,
          color: AppColors.iconRed.withOpacity(0.2),
        ),
      ),
      Positioned(
        bottom: 200,
        left: 50,
        child: Icon(
          Icons.favorite_border,
          size: 50,
          color: AppColors.iconPink.withOpacity(0.25),
        ),
      ),
      Positioned(
        bottom: 350,
        right: 20,
        child: Icon(
          Icons.favorite,
          size: 40,
          color: AppColors.iconPurple.withOpacity(0.2),
        ),
      ),
      Positioned(
        top: 100,
        left: 80,
        child: Icon(
          Icons.favorite_border,
          size: 30,
          color: AppColors.iconRed.withOpacity(0.2),
        ),
      ),
    ];
  }
}

