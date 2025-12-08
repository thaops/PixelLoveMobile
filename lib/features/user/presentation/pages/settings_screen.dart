import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/user/presentation/controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoveBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryPink,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      'Cài đặt',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPink,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Delete Account Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPink.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.errorText,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Xóa tài khoản',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.errorText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Khi xóa tài khoản, tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn và không thể khôi phục. Hành động này không thể hoàn tác.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Obx(() {
                                if (controller.isLoading) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.buttonDisabled,
                                        foregroundColor: AppColors.buttonDisabledText,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _showDeleteConfirmDialog(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.errorText,
                                      foregroundColor: AppColors.backgroundWhite,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Xóa tài khoản',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              if (controller.errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    controller.errorMessage,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.errorText,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.errorText,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Xác nhận xóa tài khoản',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài khoản? Tất cả dữ liệu sẽ bị xóa vĩnh viễn và không thể khôi phục.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorText,
              foregroundColor: AppColors.backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

