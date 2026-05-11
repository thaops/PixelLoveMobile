import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/routes/app_routes.dart';

class HomeCozyRoomButton extends StatelessWidget {
  const HomeCozyRoomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 242,
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.cozyRoom),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFffb778).withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text('🌿', style: TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }
}
