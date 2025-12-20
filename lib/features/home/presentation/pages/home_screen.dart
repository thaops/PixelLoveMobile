import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TransformationController _transformationController =
      TransformationController();
  Home? _lastHomeData;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final homeState = ref.watch(homeNotifierProvider);
    final storageService = ref.read(storageServiceProvider);
    final user = storageService.getUser();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Builder(
          builder: (context) {
            // Only show loading if no cache and still loading
            if (homeState.isLoading && homeState.homeData == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final homeData = homeState.homeData;
            if (homeData == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      homeState.errorMessage ?? 'Failed to load home data',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(homeNotifierProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                _buildInteractiveViewer(screenSize, homeData),

                // Silent update indicator (top left, subtle)
                if (homeState.isUpdating)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Profile avatar button overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: SafeArea(
                    child: Builder(
                      builder: (context) {
                        final avatarUrl = user?.avatar;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.go('/profile'),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.account_circle,
                                                color: Colors.grey,
                                                size: 28,
                                              ),
                                            );
                                          },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              color: Colors.grey.shade300,
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.account_circle,
                                        color: Colors.grey,
                                        size: 28,
                                      ),
                                    ),
                            ),
                          ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Paw floating button
                _buildPawButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInteractiveViewer(Size screenSize, Home homeData) {
    final bgWidth = homeData.background.width;
    final bgHeight = homeData.background.height;
    final bgAspectRatio = bgWidth / bgHeight;

    // Scale ảnh để cao bằng màn hình, rộng theo tỷ lệ gốc
    final finalHeight = screenSize.height;
    final finalWidth = finalHeight * bgAspectRatio;

    // Tính offset để center ảnh
    final offsetX = (finalWidth - screenSize.width) / 2;
    final offsetY = (finalHeight - screenSize.height) / 2;

    // Set initial position để center ảnh (reset khi homeData thay đổi)
    if (_lastHomeData != homeData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _transformationController.value = Matrix4.identity()
            ..translate(-offsetX, -offsetY);
          _lastHomeData = homeData;
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
                homeData.background.imageUrl.isNotEmpty
                    ? Image.network(
                        homeData.background.imageUrl,
                        width: finalWidth,
                        height: finalHeight,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/background.jpg',
                            width: finalWidth,
                            height: finalHeight,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/background.jpg',
                        width: finalWidth,
                        height: finalHeight,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                // Objects (pet, etc.)
                ...homeData.objects.map((obj) {
                  // Tính scale ratio để convert từ tọa độ gốc sang tọa độ hiển thị
                  final scaleX = finalWidth / bgWidth;
                  final scaleY = finalHeight / bgHeight;

                  return Positioned(
                    left: obj.x * scaleX,
                    top: obj.y * scaleY,
                    width: obj.width * scaleX,
                    height: obj.height * scaleY,
                      child: GestureDetector(
                      onTap: () {
                        // Nếu object là pet, navigate đến pet scene
                        if (obj.type == 'pet') {
                          context.go('/pet-scene');
                        }
                      },
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

  Widget _buildPawButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: Center(
          child: Material(
            elevation: 8,
            shape: const CircleBorder(),
            color: AppColors.primaryPink,
            shadowColor: Colors.black54,
            child: InkWell(
              onTap: () => context.go('/pet-capture'),
              customBorder: const CircleBorder(),
              child: Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryPink,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
