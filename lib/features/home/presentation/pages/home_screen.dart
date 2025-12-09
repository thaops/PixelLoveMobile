import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';
import 'package:pixel_love/features/home/presentation/controllers/home_controller.dart';
import 'package:pixel_love/features/user/presentation/controllers/user_controller.dart';
import 'package:pixel_love/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.find<HomeController>();
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

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Obx(() {
          // Only show loading if no cache and still loading
          if (controller.isLoading && controller.homeData == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final homeData = controller.homeData;
          if (homeData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Failed to load home data',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.refresh,
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
              if (controller.isUpdating)
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
                  child: GetX<UserController>(
                    builder: (userController) {
                      final user = userController.currentUser;
                      final avatarUrl = user?.avatar;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Get.toNamed(AppRoutes.profile),
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
            ],
          );
        }),
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
                          Get.toNamed(AppRoutes.petScene);
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
}
