import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/user/presentation/notifiers/onboard_notifier.dart';
import 'package:pixel_love/features/user/providers/user_providers.dart';

class OnboardScreen extends ConsumerWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardState = ref.watch(onboardNotifierProvider);

    // Handle navigation after successful onboard
    ref.listen<OnboardState>(onboardNotifierProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading) {
        if (next.errorMessage == null) {
          // Success - navigate to couple connection
          context.go('/couple-connection');
        } else {
          // Error - still navigate but show error
          context.go('/couple-connection');
        }
      }
    });

    return Scaffold(
      body: LoveBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  Column(
                    spacing: 8,
                    children: [
                      Text(
                        'Hãy bắt đầu nào!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPink,
                        ),
                      ),

                      Text(
                        'Vui lòng điền các thông tin sau.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.genderFemale,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Avatar Section
                  Center(
                    child: Builder(
                      builder: (context) {
                        final gender = onboardState.selectedGender;
                        final avatarPath = gender == 'male'
                            ? 'assets/images/avata-male.png'
                            : gender == 'female'
                            ? 'assets/images/avata-female.png'
                            : null;

                        return Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPinkLight,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryPink,
                                  width: 3,
                                ),
                              ),
                              child: avatarPath != null
                                  ? ClipOval(
                                      child: Image.asset(
                                        avatarPath,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.person,
                                                size: 60,
                                                color: AppColors.primaryPink,
                                              );
                                            },
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.primaryPink,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundWhite,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryPink,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.refresh,
                                  size: 20,
                                  color: AppColors.primaryPink,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nam button
                      _GenderBubble(
                        label: 'Nam',
                        isSelected: onboardState.selectedGender == 'male',
                        color: AppColors.genderMale,
                        onTap: () => ref
                            .read(onboardNotifierProvider.notifier)
                            .setGender('male'),
                      ),
                      const SizedBox(width: 16),
                      // Nữ button
                      _GenderBubble(
                        label: 'Nữ',
                        isSelected: onboardState.selectedGender == 'female',
                        color: AppColors.genderFemale,
                        onTap: () => ref
                            .read(onboardNotifierProvider.notifier)
                            .setGender('female'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Ngày sinh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.genderFemale,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primaryPink,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        ref
                            .read(onboardNotifierProvider.notifier)
                            .setBirthDate(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: onboardState.selectedBirthDate != null
                              ? AppColors.primaryPink
                              : AppColors.borderLight,
                          width: onboardState.selectedBirthDate != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              onboardState.selectedBirthDate == null
                                  ? 'Chọn ngày sinh'
                                  : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(onboardState.selectedBirthDate!),
                              style: TextStyle(
                                fontSize: 16,
                                color: onboardState.selectedBirthDate == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.primaryPink,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Biệt danh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.genderFemale,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Nickname Field
                  TextField(
                    onChanged: (value) => ref
                        .read(onboardNotifierProvider.notifier)
                        .setNickname(value),
                    decoration: InputDecoration(
                      hintText: 'Nhập biệt danh của bạn',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.backgroundWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryPink,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          onboardState.canSubmit && !onboardState.isLoading
                          ? () => ref
                                .read(onboardNotifierProvider.notifier)
                                .submit()
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: onboardState.canSubmit
                            ? AppColors.primaryPink
                            : AppColors.buttonDisabled,
                        foregroundColor: onboardState.canSubmit
                            ? AppColors.backgroundWhite
                            : AppColors.buttonDisabledText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: onboardState.canSubmit ? 2 : 0,
                      ),
                      child: onboardState.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.backgroundWhite,
                                ),
                              ),
                            )
                          : Text(
                              'Bước sau',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderBubble extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GenderBubble({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.5),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : color.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Mũi tên hướng về phía avatar (ở trên)
          if (isSelected)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: CustomPaint(
                  size: const Size(20, 10),
                  painter: _TrianglePainter(color: color),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Vẽ tam giác hướng lên trên (về phía avatar)
    final path = Path()
      ..moveTo(size.width / 2, 0) // Đỉnh tam giác ở trên
      ..lineTo(0, size.height) // Góc trái dưới
      ..lineTo(size.width, size.height) // Góc phải dưới
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
