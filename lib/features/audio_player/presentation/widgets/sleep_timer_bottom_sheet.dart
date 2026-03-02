import 'dart:ui';
import 'package:flutter/material.dart';

class SleepTimerBottomSheet extends StatelessWidget {
  final String? currentTimerEndsAt;
  final Function(int) onTimerSelected;

  const SleepTimerBottomSheet({
    super.key,
    this.currentTimerEndsAt,
    required this.onTimerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final timerOptions = [
      {'label': 'Hủy hẹn giờ', 'value': 0, 'icon': Icons.timer_off_outlined},
      {'label': '5 phút', 'value': 5, 'icon': Icons.timer_outlined},
      {'label': '10 phút', 'value': 10, 'icon': Icons.timer_outlined},
      {'label': '15 phút', 'value': 15, 'icon': Icons.timer_outlined},
      {'label': '30 phút', 'value': 30, 'icon': Icons.timer_outlined},
      {'label': '45 phút', 'value': 45, 'icon': Icons.timer_outlined},
      {'label': '1 giờ', 'value': 60, 'icon': Icons.more_time_outlined},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E).withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Hẹn giờ tắt nhạc',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentTimerEndsAt != null
                        ? 'Đang bật hẹn giờ'
                        : 'Chọn thời gian để tự động dừng phát nhạc',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: timerOptions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final option = timerOptions[index];
                      final isCancel = option['value'] == 0;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onTimerSelected(option['value'] as int);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  option['icon'] as IconData,
                                  color: isCancel
                                      ? Colors.redAccent
                                      : Colors.pinkAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  option['label'] as String,
                                  style: TextStyle(
                                    color: isCancel
                                        ? Colors.redAccent.withOpacity(0.9)
                                        : Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white.withOpacity(0.2),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
