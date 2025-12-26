import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

/// Reusable authentication button widget
class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String imagePath;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const AuthButton({
    super.key,
    this.onPressed,
    required this.imagePath,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(imagePath, width: 24, height: 24),
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
