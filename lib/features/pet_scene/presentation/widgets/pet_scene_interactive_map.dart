import 'package:flutter/material.dart';
import 'package:pixel_love/features/pet_scene/domain/entities/pet_scene.dart';

class PetSceneInteractiveMap extends StatelessWidget {
  final PetScene petSceneData;
  final TransformationController transformationController;

  const PetSceneInteractiveMap({
    super.key,
    required this.petSceneData,
    required this.transformationController,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bgWidth = petSceneData.background.width;
    final bgHeight = petSceneData.background.height;
    final bgAspectRatio = bgWidth / bgHeight;

    final finalHeight = screenSize.height;
    final finalWidth = finalHeight * bgAspectRatio;

    return InteractiveViewer(
      transformationController: transformationController,
      constrained: false,
      minScale: 1.0,
      maxScale: 3.0,
      panEnabled: true,
      scaleEnabled: false,
      boundaryMargin: EdgeInsets.zero,
      child: SizedBox(
        width: finalWidth,
        height: finalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildBackground(finalWidth, finalHeight),
            ..._buildObjects(finalWidth, finalHeight, bgWidth, bgHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(double width, double height) {
    if (petSceneData.background.imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade900,
        child: const Center(child: Icon(Icons.image, color: Colors.white)),
      );
    }

    return Image.network(
      petSceneData.background.imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade900,
          child: const Center(child: Icon(Icons.error, color: Colors.white)),
        );
      },
    );
  }

  List<Widget> _buildObjects(
    double finalWidth,
    double finalHeight,
    double bgWidth,
    double bgHeight,
  ) {
    final scaleX = finalWidth / bgWidth;
    final scaleY = finalHeight / bgHeight;

    return petSceneData.objects.map((obj) {
      return Positioned(
        left: obj.x * scaleX,
        top: obj.y * scaleY,
        width: obj.width * scaleX,
        height: obj.height * scaleY,
        child: ClipRect(
          child: Image.network(
            obj.imageUrl,
            fit: BoxFit.contain,
            isAntiAlias: true,
            filterQuality: FilterQuality.high,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return frame != null ? child : const SizedBox();
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.red.withValues(alpha: 0.3),
                child: const Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              );
            },
          ),
        ),
      );
    }).toList();
  }
}
