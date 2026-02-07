import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class CoupleConnectionHeader extends StatelessWidget {
  const CoupleConnectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('💕', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Kết nối với bạn đời!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Bạn sẽ trang trí không gian Couple2, nuôi thú cưng và ghi lại chuyện tình của mình.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
