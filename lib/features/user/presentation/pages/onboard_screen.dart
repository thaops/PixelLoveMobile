import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pixel_love/features/user/presentation/controllers/onboard_controller.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Màu vàng pastel nhẹ
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '😊',
                      style: TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hãy bắt đầu nào!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B6F47), // Màu nâu vàng
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng điền các thông tin sau.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),

                // Avatar Section
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFE082), // Vàng pastel
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFFFFD54F),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF8B6F47),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFFFFD54F),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: 20,
                          color: Color(0xFF8B6F47),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Gender Selection
                Text(
                  'Chọn giới tính',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B6F47),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nam button
                    _GenderBubble(
                      label: 'Nam',
                      emoji: '👨',
                      isSelected: controller.selectedGender == 'male',
                      color: Color(0xFF64B5F6), // Xanh
                      onTap: () => controller.setGender('male'),
                    ),
                    const SizedBox(width: 16),
                    // Nữ button
                    _GenderBubble(
                      label: 'Nữ',
                      emoji: '👩',
                      isSelected: controller.selectedGender == 'female',
                      color: Color(0xFFF48FB1), // Hồng
                      onTap: () => controller.setGender('female'),
                    ),
                  ],
                )),
                const SizedBox(height: 40),

                // Form Section
                // Birth Date Field
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
                              primary: Color(0xFFFFD54F),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      controller.setBirthDate(picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.selectedBirthDate != null
                            ? Color(0xFFFFD54F)
                            : Colors.grey.shade300,
                        width: controller.selectedBirthDate != null ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Color(0xFF8B6F47),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => Text(
                            controller.selectedBirthDate == null
                                ? 'Please select your birthday.'
                                : DateFormat('dd/MM/yyyy')
                                    .format(controller.selectedBirthDate!),
                            style: TextStyle(
                              fontSize: 16,
                              color: controller.selectedBirthDate == null
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Nickname Field
                TextField(
                  onChanged: (value) => controller.setNickname(value),
                  decoration: InputDecoration(
                    hintText: 'Nhập biệt danh của bạn',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(
                      Icons.edit,
                      color: Color(0xFF8B6F47),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFFFFD54F),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Submit Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.canSubmit && !controller.isLoading
                        ? () => controller.submit()
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: controller.canSubmit
                          ? Color(0xFFFFD54F)
                          : Colors.grey.shade300,
                      foregroundColor: controller.canSubmit
                          ? Color(0xFF8B6F47)
                          : Colors.grey.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: controller.canSubmit ? 2 : 0,
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF8B6F47),
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
                )),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderBubble extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GenderBubble({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

