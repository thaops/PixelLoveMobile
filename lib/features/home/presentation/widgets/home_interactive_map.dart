import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';
import 'package:pixel_love/features/radio/presentation/widgets/radio_action_menu.dart';
import 'package:pixel_love/routes/app_routes.dart';

class HomeInteractiveMap extends ConsumerWidget {
  final Home homeData;
  final TransformationController transformationController;
  final bool showRadioMenu;
  final Rect? radioRect;
  final VoidCallback onCloseRadioMenu;
  final Function(Rect) onShowRadioMenu;

  const HomeInteractiveMap({
    super.key,
    required this.homeData,
    required this.transformationController,
    required this.showRadioMenu,
    required this.radioRect,
    required this.onCloseRadioMenu,
    required this.onShowRadioMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final bgWidth = homeData.background.width;
    final bgHeight = homeData.background.height;
    final bgAspectRatio = bgWidth / bgHeight;

    final finalHeight = screenSize.height;
    final finalWidth = finalHeight * bgAspectRatio;

    final streakState = ref.watch(streakNotifierProvider);

    return InteractiveViewer(
      transformationController: transformationController,
      constrained: false,
      minScale: 1.0,
      maxScale: 3.0,
      panEnabled: true,
      scaleEnabled: false,
      boundaryMargin: EdgeInsets.zero,
      child: SizedBox(
        width: finalWidth,
        height: finalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildBackground(finalWidth, finalHeight),
            ..._buildObjects(
              context,
              ref,
              finalWidth,
              finalHeight,
              bgWidth,
              bgHeight,
              streakState.streak?.days ?? 0,
            ),
            if (showRadioMenu && radioRect != null)
              Positioned(
                left: radioRect!.center.dx - 120,
                top: radioRect!.top - 60,
                child: RadioActionMenu(
                  radioRect: radioRect!,
                  onClose: onCloseRadioMenu,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(double width, double height) {
    if (homeData.background.imageUrl.isEmpty) {
      return Image.asset(
        'assets/images/background.jpg',
        width: width,
        height: height,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      );
    }

    return CachedNetworkImage(
      imageUrl: homeData.background.imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: const Color(0xFF1A1A2E), // Dark theme primary color
        child: const Center(
          child: CircularProgressIndicator(color: Colors.pink),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/background.jpg',
        width: width,
        height: height,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }

  List<Widget> _buildObjects(
    BuildContext context,
    WidgetRef ref,
    double finalWidth,
    double finalHeight,
    double bgWidth,
    double bgHeight,
    int streakDays,
  ) {
    final scaleX = finalWidth / bgWidth;
    final scaleY = finalHeight / bgHeight;

    return homeData.objects.map((obj) {
      return Positioned(
        left: obj.x * scaleX,
        top: obj.y * scaleY,
        width: obj.width * scaleX,
        height: obj.height * scaleY,
        child: GestureDetector(
          onTap: () => _handleObjectTap(context, obj, scaleX, scaleY),
          child: ClipRect(child: _buildObjectContent(obj, streakDays)),
        ),
      );
    }).toList();
  }

  Widget _buildObjectContent(HomeObject obj, int streakDays) {
    final image = CachedNetworkImage(
      imageUrl: obj.imageUrl,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorWidget: (context, url, error) {
        return Container(
          color: Colors.red.withOpacity(0.3),
          child: const Center(child: Icon(Icons.error, color: Colors.red)),
        );
      },
      placeholder: (context, url) => const SizedBox(),
    );

    if (obj.type == 'streakStatus') {
      return Stack(
        alignment: Alignment.center,
        children: [
          image,
          Padding(
            padding: const EdgeInsets.only(top: 27, left: 5),
            child: Text(
              streakDays.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      );
    }

    return image;
  }

  void _handleObjectTap(
    BuildContext context,
    HomeObject obj,
    double scaleX,
    double scaleY,
  ) {
    if (obj.type == 'pet') {
      if (showRadioMenu) onCloseRadioMenu();
      context.push(AppRoutes.petScene);
    } else if (obj.type == 'fridge') {
      if (showRadioMenu) onCloseRadioMenu();
      context.push(AppRoutes.fridge);
    } else if (obj.type == 'radio') {
      if (showRadioMenu) {
        onCloseRadioMenu();
        return;
      }
      final radioX = obj.x * scaleX;
      final radioY = obj.y * scaleY;
      final radioW = obj.width * scaleX;
      final radioH = obj.height * scaleY;
      onShowRadioMenu(Rect.fromLTWH(radioX, radioY, radioW, radioH));
    }
  }
}
