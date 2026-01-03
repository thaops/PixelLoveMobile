import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final TransformationController _transformationController =
      TransformationController();
  Home? _lastHomeData;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Lưu transformation state mỗi khi thay đổi
    _transformationController.addListener(() {
      if (mounted) {
        ref
            .read(homeTransformationProvider.notifier)
            .updateTransformation(_transformationController.value);
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
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
            final homeData = homeState.homeData;

            // Nếu không có data, hiển thị màn hình đen (splash đã preload rồi nên sẽ có data ngay)
            // Chỉ hiển thị error nếu thực sự có lỗi
            if (homeData == null) {
              return Container(
                color: Colors.black,
                child: homeState.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              homeState.errorMessage!,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(homeNotifierProvider.notifier)
                                    .refresh();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(), // Không hiển thị gì, chỉ màn hình đen
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
                            onTap: () => context.go(AppRoutes.profile),
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
                                    ? CachedNetworkImage(
                                        imageUrl: avatarUrl,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) {
                                          return Container(
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.account_circle,
                                              color: Colors.grey,
                                              size: 28,
                                            ),
                                          );
                                        },
                                        placeholder: (context, url) {
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

    // Set initial position để center ảnh (chỉ reset khi homeData thay đổi lần đầu, giữ position khi quay về)
    if (_lastHomeData != homeData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Chỉ reset position nếu chưa được khởi tạo (lần đầu load hoặc chưa có saved state)
          // Nếu đã có saved state từ provider, nó đã được restore trong initState
          if (!_isInitialized) {
            final savedTransformation = ref.read(homeTransformationProvider);
            if (savedTransformation != null) {
              // Có saved state → dùng lại
              _transformationController.value = savedTransformation;
            } else {
              // Không có saved state → reset về center
              _transformationController.value = Matrix4.identity()
                ..translate(-offsetX, -offsetY);
            }
            _isInitialized = true;
          }
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
                // Background image (dùng Image.network như pet scene để hiển thị ngay từ memory cache)
                homeData.background.imageUrl.isNotEmpty
                    ? Image.network(
                        homeData.background.imageUrl,
                        width: finalWidth,
                        height: finalHeight,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        // Không có placeholder, hiển thị ngay nếu đã cache (splash đã preload)
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
                          context.go(AppRoutes.petScene);
                        }
                      },
                      child: ClipRect(
                        child: CachedNetworkImage(
                          imageUrl: obj.imageUrl,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorWidget: (context, url, error) {
                            return Container(
                              color: Colors.red.withOpacity(0.3),
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            );
                          },
                          placeholder: (context, url) {
                            return const SizedBox();
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
              onTap: () => context.go(AppRoutes.petCapture),
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
