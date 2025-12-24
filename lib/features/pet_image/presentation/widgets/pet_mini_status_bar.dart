import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_scene/providers/pet_scene_providers.dart';

class PetMiniStatusBar extends ConsumerWidget {
  const PetMiniStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sceneState = ref.watch(petSceneNotifierProvider);

    if (sceneState.isLoading) return _buildSkeleton();

    final petStatus = sceneState.petSceneData?.petStatus;
    if (petStatus == null) return _buildSkeleton();

    final progress = petStatus.expToNextLevel == 0
        ? 0.0
        : (petStatus.exp / petStatus.expToNextLevel).clamp(0.0, 1.0);
    final feedInfo = petStatus.todayFeedCount > 0
        ? '❤️ ${petStatus.todayFeedCount} khoảnh khắc hôm nay'
        : petStatus.lastFeedTime != null
            ? '⏰ Lần cuối: ${DateFormat('HH:mm').format(petStatus.lastFeedTime!)}'
            : '❤️ Chưa có khoảnh khắc hôm nay';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/pet-level-1.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Lv ${petStatus.level}',
                          style: TextStyle(
                            color: AppColors.primaryPink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              height: 6,
                              child: Stack(
                                children: [
                                  Container(
                                    color: AppColors.primaryPink.withOpacity(
                                      0.15,
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryPink,
                                            AppColors.primaryPinkLight,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${petStatus.exp}/${petStatus.expToNextLevel}',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feedInfo,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
    );
  }
}

