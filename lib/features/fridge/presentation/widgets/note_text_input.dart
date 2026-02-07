import 'package:flutter/material.dart';

class NoteTextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Size? imageSize;
  final VoidCallback onChanged;

  const NoteTextInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.imageSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final noteWidth = MediaQuery.of(context).size.width;
    final imageHeight = imageSize?.height ?? (noteWidth * 1.2);

    return Center(
      child: SizedBox(
        width: noteWidth,
        height: imageHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: null,
            expands: true,
            textAlign: TextAlign.start,
            textAlignVertical: const TextAlignVertical(y: -0.33),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.4,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Viết ghi chú của bạn...',
              hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
      ),
    );
  }
}
