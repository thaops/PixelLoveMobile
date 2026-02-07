import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/routes/app_routes.dart';

class FridgeCreateNoteButton extends StatelessWidget {
  const FridgeCreateNoteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: Material(
          elevation: 8,
          shape: const CircleBorder(),
          color: Colors.pink,
          shadowColor: Colors.black54,
          child: InkWell(
            onTap: () => context.go(AppRoutes.createNote),
            customBorder: const CircleBorder(),
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.edit_note, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
