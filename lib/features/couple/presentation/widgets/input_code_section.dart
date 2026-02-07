import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/couple/providers/couple_providers.dart';

class InputCodeSection extends ConsumerWidget {
  const InputCodeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleState = ref.watch(coupleConnectionNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.1),
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
          _buildInputRow(ref),
          const SizedBox(height: 12),
          _buildPartnerPreview(coupleState),
          const SizedBox(height: 12),
          _buildConnectButton(ref, coupleState),
        ],
      ),
    );
  }

  Widget _buildInputRow(WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) => ref
                .read(coupleConnectionNotifierProvider.notifier)
                .setInputCode(value),
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
                borderSide: BorderSide(color: AppColors.primaryPink, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () =>
              ref.read(coupleConnectionNotifierProvider.notifier).scanQR(),
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
    );
  }

  Widget _buildPartnerPreview(coupleState) {
    final preview = coupleState.partnerPreview;
    if (preview?.partner == null) {
      return const SizedBox.shrink();
    }

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
                ? Icon(Icons.person, color: AppColors.primaryPink, size: 20)
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

  Widget _buildConnectButton(WidgetRef ref, coupleState) {
    final isLoading = coupleState.isLoading;
    final canConnect = coupleState.canConnect;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canConnect && !isLoading
            ? () =>
                  ref.read(coupleConnectionNotifierProvider.notifier).connect()
            : null,
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Kết nối',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
