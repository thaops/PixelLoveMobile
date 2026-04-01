import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/routes/app_routes.dart';

class HomeLeaderboadButton extends StatelessWidget {
  const HomeLeaderboadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 240, // Next to music button (134 + 44 + 10 = 188)
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.leaderboard),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text('🏆', style: TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }
}
