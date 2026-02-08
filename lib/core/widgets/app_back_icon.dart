import 'package:flutter/material.dart';

class AppBackIcon extends StatelessWidget {
  final double size;

  const AppBackIcon({super.key, this.size = 66});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ic_back.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
