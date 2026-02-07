import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';

class FridgeNoteItem extends StatelessWidget {
  final FridgeNote note;
  final double width;

  const FridgeNoteItem({super.key, required this.note, this.width = 110.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CachedNetworkImage(
            imageUrl: note.frameImageUrl,
            width: width,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) {
              return Container(
                width: width,
                height: width * 1.2,
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.note, color: Colors.pink),
                ),
              );
            },
            placeholder: (context, url) {
              return Container(
                width: width,
                height: width * 1.2,
                color: Colors.grey.shade300,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Center(
                child: Text(
                  note.content,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
