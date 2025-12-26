import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

/// Error message widget for authentication screen
class AuthErrorMessage extends StatelessWidget {
  final String message;

  const AuthErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.iconRed, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.errorIcon,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.errorText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

