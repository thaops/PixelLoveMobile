import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/radio/domain/entities/voice.dart';
import 'package:pixel_love/features/radio/presentation/widgets/mood_color.dart';

class VoiceListItem extends StatelessWidget {
  final Voice voice;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const VoiceListItem({
    super.key,
    required this.voice,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final moodColor = getMoodColor(voice.mood);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(voice.id),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (_) => onPin(),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              backgroundColor: voice.isPinned
                  ? Colors.grey.shade700
                  : AppColors.primaryPink,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      voice.isPinned
                          ? Icons.push_pin_outlined
                          : Icons.push_pin_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voice.isPinned ? 'Bỏ ghim' : 'Ghim',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.25,
          dismissible: DismissiblePane(
            onDismissed: onDelete,
            closeOnCancel: true,
            confirmDismiss: () async {
              return await _showDeleteConfirm(context);
            },
          ),
          children: [
            CustomSlidableAction(
              onPressed: (_) async {
                final confirm = await _showDeleteConfirm(context);
                if (confirm) onDelete();
              },
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(20),
              ),
              backgroundColor: const Color(0xFFFF4757),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Xóa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isCurrent
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: voice.isPinned
                  ? AppColors.primaryPink.withOpacity(0.6)
                  : (isCurrent
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white.withOpacity(0.15)),
              width: voice.isPinned ? 2 : 1,
            ),
            boxShadow: voice.isPinned
                ? [
                    BoxShadow(
                      color: AppColors.primaryPink.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                moodColor.withOpacity(0.3),
                                moodColor.withOpacity(0.15),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: moodColor, width: 2),
                          ),
                          child: Icon(
                            isCurrent && isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: moodColor,
                            size: 28,
                          ),
                        ),
                        if (voice.isPinned)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFF6B9D),
                                    Color(0xFFFF8E53),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.push_pin_rounded,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voice.text,
                            style: TextStyle(
                              color: AppColors.primaryPink,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: moodColor.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: moodColor.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  voice.mood,
                                  style: TextStyle(
                                    color: moodColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${voice.duration}s',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                dateFormat.format(voice.takenAt),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirm(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2D1B4E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Color(0xFFFF4757),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Xác nhận xóa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'Bạn có chắc muốn xóa voice message này? Hành động này không thể hoàn tác.',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Hủy',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4757), Color(0xFFFF6B7A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4757).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Xóa',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
