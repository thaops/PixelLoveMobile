import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/routes/app_routes.dart';

class PetSceneAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PetSceneAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.home);
          }
        },
      ),
      actions: [
        IconButton(
          onPressed: () => context.go(AppRoutes.petAlbumSwipe),
          icon: const Icon(Icons.photo_library, color: Colors.white),
          tooltip: 'Xem Album Kỷ Niệm',
        ),
      ],
    );
  }
}
