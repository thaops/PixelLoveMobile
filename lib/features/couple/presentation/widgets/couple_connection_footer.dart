import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class CoupleConnectionFooter extends StatelessWidget {
  const CoupleConnectionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: Text(
          'Chưa có bạn đời?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primaryPink,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
