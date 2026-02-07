import 'package:flutter/material.dart';
import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';

class FridgeBackgroundImage extends StatelessWidget {
  final FridgeBackground background;

  const FridgeBackgroundImage({super.key, required this.background});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned.fill(
      child: Image.network(
        background.imageUrl,
        fit: BoxFit.cover,
        width: size.width,
        height: size.height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(Icons.error_outline, color: Colors.white54, size: 48),
            ),
          );
        },
      ),
    );
  }
}
