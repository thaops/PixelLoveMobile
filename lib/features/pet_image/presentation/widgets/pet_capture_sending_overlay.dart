import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class PetCaptureSendingOverlay extends StatelessWidget {
  const PetCaptureSendingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: keyboardHeight > 0 ? keyboardHeight : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.backgroundGradient.last.withOpacity(0.9),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryPink,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}


