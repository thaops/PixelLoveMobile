import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';

class HomeController {
  final WidgetRef ref;
  final TransformationController transformationController;
  final VoidCallback onStateChanged;

  Home? lastHomeData;
  bool isInitialized = false;
  bool showRadioMenu = false;
  Rect? radioRect;

  HomeController({
    required this.ref,
    required this.transformationController,
    required this.onStateChanged,
  });

  void init() {
    transformationController.addListener(_onTransformationChanged);
  }

  void dispose() {
    transformationController.removeListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    ref
        .read(homeTransformationProvider.notifier)
        .updateTransformation(transformationController.value);
  }

  void initializePosition(Home homeData, Size screenSize) {
    if (lastHomeData == homeData) return;

    final bgWidth = homeData.background.width;
    final bgHeight = homeData.background.height;
    final bgAspectRatio = bgWidth / bgHeight;

    final finalHeight = screenSize.height;
    final finalWidth = finalHeight * bgAspectRatio;

    final offsetX = (finalWidth - screenSize.width) / 2;
    final offsetY = (finalHeight - screenSize.height) / 2;

    if (!isInitialized) {
      final savedTransformation = ref.read(homeTransformationProvider);
      if (savedTransformation != null) {
        transformationController.value = savedTransformation;
      } else {
        transformationController.value = Matrix4.identity()
          ..translate(-offsetX, -offsetY);
      }
      isInitialized = true;
    }
    lastHomeData = homeData;
  }

  void toggleRadioMenu(Rect rect) {
    if (showRadioMenu) {
      closeRadioMenu();
    } else {
      radioRect = rect;
      showRadioMenu = true;
      onStateChanged();
    }
  }

  void closeRadioMenu() {
    showRadioMenu = false;
    onStateChanged();
  }

  void retry() {
    ref.read(homeNotifierProvider.notifier).refresh();
  }
}
