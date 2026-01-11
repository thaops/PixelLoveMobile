import 'dart:ui';
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
import 'package:pixel_love/features/radio/presentation/widgets/radio_action_menu.dart';

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
  bool _showRadioMenu = false;
  Rect? _radioRect;

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
                            onTap: () => context.push(AppRoutes.profile),
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
                                            child: Image.asset(
                                              'assets/images/avata-male.png',
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
                                        child: Image.asset(
                                          'assets/images/avata-male.png',
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
                // Bottom Action Bar
                _buildBottomActions(),
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
                    : GestureDetector(
                        onTap: () {
                          if (_showRadioMenu) {
                            setState(() => _showRadioMenu = false);
                          }
                        },
                        child: Image.asset(
                          'assets/images/background.jpg',
                          width: finalWidth,
                          height: finalHeight,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
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
                        if (obj.type == 'pet') {
                          if (_showRadioMenu)
                            setState(() => _showRadioMenu = false);
                          context.go(AppRoutes.petScene);
                        } else if (obj.type == 'fridge') {
                          if (_showRadioMenu)
                            setState(() => _showRadioMenu = false);
                          context.go(AppRoutes.fridge);
                        } else if (obj.type == 'radio') {
                          if (_showRadioMenu) {
                            setState(() => _showRadioMenu = false);
                            return;
                          }
                          final radioX = obj.x * scaleX;
                          final radioY = obj.y * scaleY;
                          final radioW = obj.width * scaleX;
                          final radioH = obj.height * scaleY;
                          setState(() {
                            _radioRect = Rect.fromLTWH(
                              radioX,
                              radioY,
                              radioW,
                              radioH,
                            );
                            _showRadioMenu = true;
                          });
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

                if (_showRadioMenu && _radioRect != null)
                  Positioned(
                    left: _radioRect!.center.dx - 120,
                    top: _radioRect!.top - 60,
                    child: RadioActionMenu(
                      radioRect: _radioRect!,
                      onClose: () => setState(() => _showRadioMenu = false),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 30,
      child: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.05),
                  ],
                  stops: const [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    Icons.photo_library_rounded,
                    () => context.go(AppRoutes.petAlbumSwipe),
                  ),
                  _buildActionButton(
                    Icons.pets_rounded,
                    () => context.go(AppRoutes.petScene),
                  ),
                  _buildCenterShutterButton(),
                  _buildActionButton(
                    Icons.kitchen_rounded,
                    () => context.go(AppRoutes.fridge),
                  ),
                  _buildActionButton(
                    Icons.radio_rounded,
                    () => context.go(AppRoutes.radio),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: AppColors.textPrimary.withOpacity(0.8),
            size: 26,
            shadows: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterShutterButton() {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.petCapture),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryPink, AppColors.primaryPink.withRed(200)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(width: 2, color: Colors.white),
        ),
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
