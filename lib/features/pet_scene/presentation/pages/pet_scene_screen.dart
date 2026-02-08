import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/widgets/background_loading_screen.dart';
import 'package:pixel_love/core/widgets/custom_loading_widget.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/pet_scene/presentation/controllers/pet_scene_controller.dart';
import 'package:pixel_love/core/widgets/pixel_love_app_bar.dart';
import 'package:pixel_love/features/pet_scene/presentation/widgets/pet_scene_error_view.dart';
import 'package:pixel_love/features/pet_scene/presentation/widgets/pet_scene_interactive_map.dart';
import 'package:pixel_love/features/pet_scene/presentation/widgets/pet_status_card.dart';
import 'package:pixel_love/features/pet_scene/providers/pet_scene_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';

class PetSceneScreen extends ConsumerStatefulWidget {
  const PetSceneScreen({super.key});

  @override
  ConsumerState<PetSceneScreen> createState() => _PetSceneScreenState();
}

class _PetSceneScreenState extends ConsumerState<PetSceneScreen> {
  final _transformationController = TransformationController();
  late PetSceneController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PetSceneController(
      ref: ref,
      context: context,
      transformationController: _transformationController,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sceneState = ref.watch(petSceneNotifierProvider);

    if (sceneState.isLoading || sceneState.petSceneData == null) {
      return Scaffold(
        body: LoveBackground(
          showDecorativeIcons: true,
          child: const Center(child: CustomLoadingWidget(size: 120)),
        ),
      );
    }

    final petSceneData = sceneState.petSceneData!;
    final backgroundUrl = petSceneData.background.imageUrl;

    if (!_controller.backgroundLoaded && backgroundUrl.isNotEmpty) {
      _schedulePreload(backgroundUrl);
      return BackgroundLoadingScreen(
        backgroundImageUrl: backgroundUrl,
        title: 'Đang tải khung cảnh',
        subtitle: 'Vui lòng đợi...',
        onLoadComplete: () {},
        onLoadError: _controller.onLoadError,
      );
    }

    if (_controller.isPreloading) {
      return BackgroundLoadingScreen(
        backgroundImageUrl: backgroundUrl,
        title: 'Đang tải khung cảnh',
        subtitle: 'Vui lòng đợi...',
        onLoadComplete: () {},
        onLoadError: _controller.onLoadError,
      );
    }

    _schedulePositionInit(petSceneData);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !context.canPop()) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && context.mounted) {
              context.go(AppRoutes.home);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: const PixelLoveAppBar(
          leadingPadding: EdgeInsets.only(left: 20),
          leadingWidth: 90,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: _buildBody(sceneState, petSceneData),
        ),
      ),
    );
  }

  Widget _buildBody(sceneState, petSceneData) {
    if (sceneState.errorMessage != null && sceneState.petSceneData == null) {
      return PetSceneErrorView(
        errorMessage: sceneState.errorMessage!,
        onRetry: _controller.retry,
      );
    }

    return Stack(
      children: [
        PetSceneInteractiveMap(
          petSceneData: petSceneData,
          transformationController: _transformationController,
        ),
        Positioned(
          top: 100,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PetStatusCard(petStatus: petSceneData.petStatus),
              const SizedBox(height: 16),
              _buildSideButton(
                'assets/images/ic_tab_camera.png',
                () => context.push(AppRoutes.petCapture),
              ),
              const SizedBox(height: 12),
              _buildSideButton(
                'assets/images/ic_tab_acsset.png',
                () => context.push(AppRoutes.petAlbumSwipe),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _schedulePreload(String backgroundUrl) {
    if (_controller.isPreloading) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.preloadBackground(backgroundUrl);
    });
  }

  void _schedulePositionInit(petSceneData) {
    if (_controller.lastPetSceneData == petSceneData) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.initializePosition(
          petSceneData,
          MediaQuery.of(context).size,
        );
      }
    });
  }

  Widget _buildSideButton(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        height: 66,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(asset),
      ),
    );
  }
}
