import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/custom_loading_widget.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/startup/startup_controller.dart';

class SplashScreen extends GetView<StartupController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoveBackground(
        showDecorativeIcons: false,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Opacity(
                opacity: 1,
                child: Image.asset(
                  'assets/images/backgroud-splash.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    if (controller.isLoading) {
                      return const CustomLoadingWidget(showBackdrop: false);
                    } else if (controller.errorMessage.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          controller.errorMessage,
                          style: TextStyle(color: AppColors.errorText),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
