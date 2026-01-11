import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

Color getMoodColor(String mood) {
  switch (mood.toLowerCase()) {
    case 'love':
      return const Color(0xFFFF6B9D);
    case 'happy':
      return const Color(0xFFFFD93D);
    case 'sad':
      return const Color(0xFF6BCB77);
    case 'angry':
      return const Color(0xFFFF6B6B);
    case 'neutral':
      return const Color(0xFF4ECDC4);
    default:
      return AppColors.primaryPink;
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}
