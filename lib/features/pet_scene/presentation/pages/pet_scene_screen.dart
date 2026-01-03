import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/features/pet_scene/domain/entities/pet_scene.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/features/pet_scene/providers/pet_scene_providers.dart';
import 'package:pixel_love/core/widgets/background_loading_screen.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/core/widgets/custom_loading_widget.dart';
import 'package:pixel_love/core/utils/image_loader_utils.dart';

class PetSceneScreen extends ConsumerStatefulWidget {
  const PetSceneScreen({super.key});

  @override
  ConsumerState<PetSceneScreen> createState() => _PetSceneScreenState();
}

class _PetSceneScreenState extends ConsumerState<PetSceneScreen> {
  final TransformationController _transformationController =
      TransformationController();
  PetScene? _lastPetSceneData;
  bool _backgroundLoaded = false;
  bool _isPreloading = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Preload và đợi background render xong (giống splash screen)
  Future<void> _preloadAndWaitForBackground(String imageUrl) async {
    if (_isPreloading || _backgroundLoaded) return;

    setState(() {
      _isPreloading = true;
    });

    try {
      if (imageUrl.isNotEmpty && mounted) {
        final imageProvider = NetworkImage(imageUrl);
        final rendered = await ImageLoaderUtils.waitForImageToRender(
          imageProvider,
          context,
        );
        if (rendered) {
          print('✅ Pet scene background image rendered successfully');
        } else {
          print('⚠️ Timeout or error rendering image, proceeding anyway');
        }
      }
    } catch (e) {
      print('⚠️ Preload error: $e');
      // Vẫn tiếp tục dù preload lỗi
    } finally {
      if (mounted) {
        setState(() {
          _isPreloading = false;
          _backgroundLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final canPop = context.canPop();
    final sceneState = ref.watch(petSceneNotifierProvider);

    // Nếu đang loading data hoặc chưa có data, hiển thị loading với LoveBackground
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

    // Preload background trước khi hiển thị màn hình (giống splash)
    if (!_backgroundLoaded && backgroundUrl.isNotEmpty && !_isPreloading) {
      // Trigger preload
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preloadAndWaitForBackground(backgroundUrl);
      });

      // Hiển thị loading screen với progress trong lúc preload
      return BackgroundLoadingScreen(
        backgroundImageUrl: backgroundUrl,
        title: 'Đang tải khung cảnh',
        subtitle: 'Vui lòng đợi...',
        onLoadComplete: () {
          // onLoadComplete sẽ được gọi từ BackgroundLoadingScreen
          // Nhưng chúng ta cũng cần đợi preload xong
          // Nên không set _backgroundLoaded ở đây
        },
        onLoadError: () {
          // Nếu load lỗi, vẫn cho vào màn hình (fallback)
          if (mounted) {
            setState(() {
              _backgroundLoaded = true;
            });
          }
        },
      );
    }

    // Nếu đang preload, vẫn hiển thị loading screen
    if (_isPreloading) {
      return BackgroundLoadingScreen(
        backgroundImageUrl: backgroundUrl,
        title: 'Đang tải khung cảnh',
        subtitle: 'Vui lòng đợi...',
        onLoadComplete: () {
          // Không làm gì, đợi _preloadAndWaitForBackground xong
        },
        onLoadError: () {
          if (mounted) {
            setState(() {
              _backgroundLoaded = true;
            });
          }
        },
      );
    }

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop && !canPop) {
          // If cannot pop, navigate to home instead of exiting app
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
        appBar: AppBar(
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
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Builder(
            builder: (context) {
              // Hiển thị error nếu có
              if (sceneState.errorMessage != null &&
                  sceneState.petSceneData == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sceneState.errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(petSceneNotifierProvider.notifier)
                              .fetchPetScene();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // Hiển thị pet scene
              return Stack(
                children: [
                  _buildInteractiveViewer(screenSize, petSceneData),

                  // Pet status info overlay (bottom)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: SafeArea(
                      child: _buildPetStatusCard(petSceneData.petStatus),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveViewer(Size screenSize, PetScene petSceneData) {
    final bgWidth = petSceneData.background.width;
    final bgHeight = petSceneData.background.height;
    final bgAspectRatio = bgWidth / bgHeight;

    // Scale ảnh để cao bằng màn hình, rộng theo tỷ lệ gốc
    final finalHeight = screenSize.height;
    final finalWidth = finalHeight * bgAspectRatio;

    // Tính offset để center ảnh
    final offsetX = (finalWidth - screenSize.width) / 2;
    final offsetY = (finalHeight - screenSize.height) / 2;

    // Set initial position để center ảnh (reset khi petSceneData thay đổi)
    if (_lastPetSceneData != petSceneData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _transformationController.value = Matrix4.identity()
            ..translate(-offsetX, -offsetY);
          _lastPetSceneData = petSceneData;
        }
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          transformationController: _transformationController,
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
                // Background image
                petSceneData.background.imageUrl.isNotEmpty
                    ? Image.network(
                        petSceneData.background.imageUrl,
                        width: finalWidth,
                        height: finalHeight,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade900,
                            child: const Center(
                              child: Icon(Icons.error, color: Colors.white),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.white),
                        ),
                      ),
                // Objects
                ...petSceneData.objects.map((obj) {
                  // Tính scale ratio để convert từ tọa độ gốc sang tọa độ hiển thị
                  final scaleX = finalWidth / bgWidth;
                  final scaleY = finalHeight / bgHeight;

                  return Positioned(
                    left: obj.x * scaleX,
                    top: obj.y * scaleY,
                    width: obj.width * scaleX,
                    height: obj.height * scaleY,
                    child: ClipRect(
                      child: Image.network(
                        obj.imageUrl,
                        fit: BoxFit.contain,
                        isAntiAlias: true,
                        filterQuality: FilterQuality.high,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) return child;
                              return frame != null ? child : const SizedBox();
                            },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.red.withOpacity(0.3),
                            child: const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetStatusCard(PetStatus petStatus) {
    final expProgress = petStatus.exp / petStatus.expToNextLevel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Level ${petStatus.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXP: ${petStatus.exp} / ${petStatus.expToNextLevel}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: expProgress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (petStatus.todayFeedCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Fed ${petStatus.todayFeedCount} time(s) today',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
