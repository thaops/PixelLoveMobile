import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/test_map/models/home_response.dart';
import 'package:pixel_love/routes/app_routes.dart';

class TestMap extends StatefulWidget {
  const TestMap({super.key});

  @override
  State<TestMap> createState() => _TestMapState();
}

class _TestMapState extends State<TestMap> {
  final TransformationController _controller = TransformationController();
  bool _initialized = false;
  bool _isLoading = true;
  HomeResponse? _homeData;

  // Kích thước ảnh gốc (mặc định)
  static const imageWidth = 4096.0;
  static const imageHeight = 1920.0;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    try {
      final dioApi = Get.find<DioApi>();
      final result = await dioApi.get<HomeResponse>(
        '/home',
        fromJson: (json) => HomeResponse.fromJson(json),
      );

      result.when(
        success: (data) {
          if (mounted) {
            setState(() {
              _homeData = data;
              _isLoading = false;
              _initialized = false; // Reset để init lại với kích thước mới
            });
          }
        },
        error: (error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initPosition(Size screenSize, double finalWidth, double finalHeight) {
    if (_initialized) return;
    _initialized = true;

    // Tính offset để ảnh hiển thị ở giữa
    final offsetX = (finalWidth - screenSize.width) / 2;
    final offsetY = (finalHeight - screenSize.height) / 2;

    // Set vị trí ban đầu (dịch chuyển ngược để center)
    _controller.value = Matrix4.identity()..translate(-offsetX, -offsetY);
  }

  Widget _buildInteractiveViewer(Size screenSize) {
    // Lấy kích thước từ API hoặc dùng mặc định
    final bgWidth = _homeData?.background.width ?? imageWidth;
    final bgHeight = _homeData?.background.height ?? imageHeight;
    final bgAspectRatio = bgWidth / bgHeight;

    // Scale ảnh để cao bằng màn hình, rộng theo tỷ lệ gốc
    final finalHeight = screenSize.height;
    final finalWidth = finalHeight * bgAspectRatio;

    // Khởi tạo vị trí center
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPosition(screenSize, finalWidth, finalHeight);
    });

    return InteractiveViewer(
      transformationController: _controller,
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
          children: [
            // Background image
            _homeData != null && _homeData!.background.imageUrl.isNotEmpty
                ? Image.network(
                    _homeData!.background.imageUrl,
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
            ...(_homeData?.objects ?? []).map((obj) {
              // Tính scale ratio để convert từ tọa độ gốc sang tọa độ hiển thị
              final scaleX = finalWidth / bgWidth;
              final scaleY = finalHeight / bgHeight;

              return Positioned(
                left: obj.x * scaleX,
                top: obj.y * scaleY,
                width: obj.width * scaleX,
                height: obj.height * scaleY,
                child: RepaintBoundary(
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
        child: Stack(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else
              _buildInteractiveViewer(screenSize),
            // Nút Profile overlay ở tầng cao nhất
            SafeArea(
              child: Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.profile),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
