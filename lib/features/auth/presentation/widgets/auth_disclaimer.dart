import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

/// Disclaimer text widget for authentication screen
class AuthDisclaimer extends StatelessWidget {
  const AuthDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
          children: [
            const TextSpan(text: 'Bằng cách tiếp tục, bạn đồng ý với '),
            TextSpan(
              text: 'Điều khoản sử dụng',
              style: TextStyle(
                color: AppColors.primaryPink,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' và '),
            TextSpan(
              text: 'Chính sách bảo mật',
              style: TextStyle(
                color: AppColors.primaryPink,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' của chúng tôi'),
          ],
        ),
      ),
    );
  }
}
