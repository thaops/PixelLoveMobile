import 'package:flutter/material.dart';
import 'package:pixel_love/features/pet_scene/domain/entities/pet_scene.dart';

class PetStatusCard extends StatelessWidget {
  final PetStatus petStatus;

  const PetStatusCard({super.key, required this.petStatus});

  @override
  Widget build(BuildContext context) {
    double progress = 0.0;
    if (petStatus.expToNextLevel > 0) {
      progress = petStatus.exp / (petStatus.exp + petStatus.expToNextLevel);
    }
    // Camp progress between 0 and 1
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0) progress = 0.0;

    return Container(
      width: 60, // Fixed width for vertical pill
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFEEF5), // Light pink
            Color(0xFFFFC1E3), // Darker pink
          ],
        ),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 3),
        boxShadow: [
          // 3D Shadow effect
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            offset: const Offset(4, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-2, -2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFFFF0F5),
              backgroundImage: AssetImage('assets/images/pet-level-1.png'),
            ),
          ),
          const SizedBox(height: 12),

          // Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4081),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4081).withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Lv.${petStatus.level}',
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 140,
              width: 12,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Background track
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Fill
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: constraints.maxHeight * progress,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFFFF80AB), Color(0xFFFF4081)],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          if (petStatus.todayFeedCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fastfood_rounded,
                size: 18,
                color: Color(0xFFFF4081),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
