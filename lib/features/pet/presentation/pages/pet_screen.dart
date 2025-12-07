import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_love/features/pet/presentation/controllers/pet_controller.dart';

class PetScreen extends GetView<PetController> {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pet'),
        actions: [
          IconButton(
            onPressed: controller.fetchPetStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.pet == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final pet = controller.pet;

        if (pet == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load pet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchPetStatus,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPetStatus,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.pink.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 80,
                            color: Colors.pink.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Level ${pet.level}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${pet.status.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatBar(
                          label: 'EXP',
                          value: pet.exp,
                          maxValue: pet.maxExp,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        _buildStatBar(
                          label: 'Hunger',
                          value: pet.hunger,
                          maxValue: 100,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        _buildStatBar(
                          label: 'Happiness',
                          value: pet.happiness,
                          maxValue: 100,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (pet.isHungry)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Your pet is hungry! Feed it now.',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading ? null : controller.feedPet,
                    icon: const Icon(Icons.restaurant),
                    label: const Text(
                      'Feed Pet',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatBar({
    required String label,
    required int value,
    required int maxValue,
    required Color color,
  }) {
    final progress = value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value / $maxValue',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
