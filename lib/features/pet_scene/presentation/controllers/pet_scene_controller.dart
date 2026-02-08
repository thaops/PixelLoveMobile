import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/utils/image_loader_utils.dart';
import 'package:pixel_love/features/pet_scene/domain/entities/pet_scene.dart';
import 'package:pixel_love/features/pet_scene/providers/pet_scene_providers.dart';

class PetSceneController {
  final WidgetRef ref;
  final BuildContext context;
  final TransformationController transformationController;
  final VoidCallback onStateChanged;

  PetScene? lastPetSceneData;
  bool backgroundLoaded = false;
  bool isPreloading = false;

  PetSceneController({
    required this.ref,
    required this.context,
    required this.transformationController,
    required this.onStateChanged,
  });

  Future<void> preloadBackground(String imageUrl) async {
    if (isPreloading || backgroundLoaded) return;

    isPreloading = true;
    onStateChanged();

    try {
      if (imageUrl.isNotEmpty) {
        final imageProvider = NetworkImage(imageUrl);
        await ImageLoaderUtils.waitForImageToRender(imageProvider, context);
      }
    } catch (_) {
    } finally {
      isPreloading = false;
      backgroundLoaded = true;
      onStateChanged();
    }
  }

  void initializePosition(PetScene petSceneData, Size screenSize) {
    if (lastPetSceneData == petSceneData) return;

    final bgWidth = petSceneData.background.width;
    final bgHeight = petSceneData.background.height;
    final bgAspectRatio = bgWidth / bgHeight;

    final finalHeight = screenSize.height;
    final finalWidth = finalHeight * bgAspectRatio;

    // Center horizontally then shift right by 150
    double offsetX = (finalWidth - screenSize.width) / 2 + 100;

    // Clamp to ensure we don't go past the right edge
    final maxOffsetX = finalWidth - screenSize.width;
    if (offsetX > maxOffsetX) offsetX = maxOffsetX;
    if (offsetX < 0) offsetX = 0;

    final offsetY = (finalHeight - screenSize.height) / 2;

    transformationController.value = Matrix4.identity()
      ..translate(-offsetX, -offsetY);
    lastPetSceneData = petSceneData;
  }

  void onLoadError() {
    backgroundLoaded = true;
    onStateChanged();
  }

  void retry() {
    ref.read(petSceneNotifierProvider.notifier).fetchPetScene();
  }
}
