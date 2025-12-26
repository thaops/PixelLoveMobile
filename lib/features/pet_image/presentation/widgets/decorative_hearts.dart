import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class DecorativeHearts extends StatelessWidget {
  const DecorativeHearts({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 100,
          left: 30,
          child: Icon(
            Icons.favorite,
            size: 50,
            color: AppColors.iconPurple.withOpacity(0.3),
          ),
        ),
        Positioned(
          bottom: 180,
          right: 40,
          child: Icon(
            Icons.favorite_border,
            size: 45,
            color: AppColors.iconPurple.withOpacity(0.25),
          ),
        ),
        Positioned(
          bottom: 750,
          left: 60,
          child: Icon(
            Icons.favorite,
            size: 40,
            color: AppColors.iconPurple.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}

