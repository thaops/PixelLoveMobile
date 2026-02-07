import 'package:flutter/material.dart';

class SplashBackgroundImage extends StatelessWidget {
  const SplashBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 1,
        child: Image.asset(
          'assets/images/backgroud-splash.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
