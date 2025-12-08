import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Màu hồng chủ đạo
  static const Color primaryPink = Color(0xFFFF6B9D);
  static const Color primaryPinkLight = Color(0xFFFFE5F1);
  static const Color primaryPinkDark = Color(0xFFFF4A7A);

  // Background Gradient Colors
  static const Color gradientPink = Color(0xFFFFE5F1); // Pastel pink
  static const Color gradientCream = Color(0xFFFFF4E6); // Cream yellow
  static const Color gradientGreen = Color(0xFFE8F5E9); // Pastel green

  // Text Colors
  static const Color textPrimary = Color(0xFF4A4A4A);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color textLight = Color(0xFF9E9E9E);

  // Decorative Icon Colors
  static Color iconPink = Colors.pink.shade200;
  static Color iconPurple = Colors.purple.shade200;
  static Color iconRed = Colors.red.shade200;

  // Border & Divider Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);

  // Background Colors
  static const Color backgroundWhite = Colors.white;
  static const Color backgroundLight = Color(0xFFF5F5F5);

  // Error & Success Colors
  static const Color errorBackground = Color(0xFFFFEBEE);
  static Color errorText = Colors.red.shade700;
  static Color errorIcon = Colors.red.shade400;
  static const Color successGreen = Color(0xFF4CAF50);

  // Gender Selection Colors
  static const Color genderMale = Color(0xFF64B5F6);
  static const Color genderFemale = Color(0xFFF48FB1);

  // Button Colors
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonDisabledText = Color(0xFF9E9E9E);

  // Gradient List
  static List<Color> get backgroundGradient => [
        gradientPink,
        gradientCream,
        gradientGreen,
      ];
}

