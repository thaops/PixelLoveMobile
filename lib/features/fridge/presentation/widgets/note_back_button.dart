import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/core/widgets/app_back_icon.dart';

class NoteBackButton extends StatelessWidget {
  const NoteBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.fridge);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const AppBackIcon(),
          ),
        ),
      ),
    );
  }
}
