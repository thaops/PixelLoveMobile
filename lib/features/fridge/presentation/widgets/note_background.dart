import 'package:flutter/material.dart';

class NoteBackground extends StatelessWidget {
  final GlobalKey imageKey;
  final VoidCallback onImageLoaded;

  const NoteBackground({
    super.key,
    required this.imageKey,
    required this.onImageLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final noteWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        key: imageKey,
        width: noteWidth,
        height: noteWidth * 1.2,
        child: Image.asset(
          'assets/images/note_pink.png',
          width: noteWidth,
          height: noteWidth * 1.2,
          fit: BoxFit.contain,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame != null) {
              onImageLoaded();
            }
            return child;
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: noteWidth,
              height: noteWidth * 1.2,
              decoration: BoxDecoration(
                color: Colors.pink.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.note, color: Colors.pink, size: 64),
              ),
            );
          },
        ),
      ),
    );
  }
}
