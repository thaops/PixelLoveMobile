import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/routes/app_routes.dart';

class HomeBottomActionBar extends StatelessWidget {
  const HomeBottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: Platform.isIOS ? 10 : 30,
      child: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionButton(
                    assetPath: 'assets/images/ic_tab_acsset.png',
                    onTap: () => context.go(AppRoutes.petAlbumSwipe),
                  ),
                  _ActionButton(
                    assetPath: 'assets/images/ic_tab_pet.png',
                    onTap: () => context.go(AppRoutes.petScene),
                  ),
                  _CenterShutterButton(),
                  _ActionButton(
                    assetPath: 'assets/images/ic_tab_fridge.png',
                    onTap: () => context.go(AppRoutes.fridge),
                  ),
                  _ActionButton(
                    assetPath: 'assets/images/ic_tab_radio.png',
                    onTap: () => context.go(AppRoutes.radio),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const _ActionButton({required this.assetPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 50,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _CenterShutterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.petCapture),
      child: SizedBox(
        width: 75,
        height: 75,
        child: Image.asset(
          'assets/images/ic_tab_camera.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
