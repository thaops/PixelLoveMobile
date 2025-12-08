import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/couple/presentation/controllers/couple_connection_controller.dart';
import 'package:pixel_love/routes/app_routes.dart';

class CoupleConnectionScreen extends GetView<CoupleConnectionController> {
  const CoupleConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoveBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPinkLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.settings,
                          color: AppColors.primaryPink,
                          size: 24,
                        ),
                      ),
                      onPressed: () {
                        Get.toNamed(AppRoutes.settings);
                      },
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
                        const SizedBox(height: 8),
                        // Header
                        _buildHeader(),
                        const SizedBox(height: 24),
                        // Share Code Section
                        _buildShareCodeSection(),
                        const SizedBox(height: 16),
                        // Input Code Section
                        _buildInputCodeSection(),
                        const SizedBox(height: 16),
                        // Footer link
                        _buildFooterLink(),
                        const SizedBox(height: 24),
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

  Widget _buildHeader() {
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

  Widget _buildShareCodeSection() {
    return Obx(() {
      final code = controller.coupleCode;
      if (code == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gửi mã ghép',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // Code display with copy button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 18),
                Text(
                  code.code,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPink,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(width: 8),
                InkWell(
                  onTap: controller.copyCode,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryPink),
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: AppColors.primaryPink,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // QR Code and Share button in row
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Center(
                child: Icon(
                  Icons.qr_code,
                  size: 60,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInputCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'Nhập mã ghép nối của đối tác bạn',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Input field with scan button
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: controller.setInputCode,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã ghép nối',
                    hintStyle: TextStyle(color: AppColors.textLight),
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryPink,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: controller.scanQR,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPinkLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.primaryPink,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Partner preview
          Obx(() {
            final preview = controller.partnerPreview;
            if (preview?.partner != null) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gradientGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryPinkLight,
                      backgroundImage: preview!.partner!.avatar != null
                          ? NetworkImage(preview.partner!.avatar!)
                          : null,
                      child: preview.partner!.avatar == null
                          ? Icon(
                              Icons.person,
                              color: AppColors.primaryPink,
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preview.partner!.name ?? 'Người dùng',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (preview.partner!.email != null)
                            Text(
                              preview.partner!.email!,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 12),
          // Connect button
          Obx(() {
            final isLoading = controller.isLoading;
            final canConnect =
                controller.canConnect &&
                controller.partnerPreview?.canPair == true;

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canConnect && !isLoading ? controller.connect : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canConnect
                      ? AppColors.primaryPink
                      : AppColors.buttonDisabled,
                  foregroundColor: canConnect
                      ? AppColors.backgroundWhite
                      : AppColors.buttonDisabledText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: canConnect ? 2 : 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Kết nối',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooterLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          // TODO: Navigate to other flow
        },
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
