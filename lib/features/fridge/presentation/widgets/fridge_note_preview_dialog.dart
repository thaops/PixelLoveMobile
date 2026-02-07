import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';

class FridgeNotePreviewDialog extends StatelessWidget {
  final FridgeNote note;

  const FridgeNotePreviewDialog({super.key, required this.note});

  static void show(BuildContext context, FridgeNote note) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      barrierDismissible: true,
      builder: (_) => FridgeNotePreviewDialog(note: note),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: note.frameImageUrl,
              width: 380,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) {
                return Container(
                  width: 380,
                  height: 380 * 1.2,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.note, color: Colors.pink, size: 48),
                  ),
                );
              },
              placeholder: (context, url) {
                return Container(
                  width: 380,
                  height: 380 * 1.2,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      note.content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
