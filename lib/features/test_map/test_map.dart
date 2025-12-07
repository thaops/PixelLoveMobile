import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestMap extends StatefulWidget {
  const TestMap({super.key});

  @override
  State<TestMap> createState() => _TestMapState();
}

class _TestMapState extends State<TestMap> {
  final TransformationController _controller = TransformationController();
  bool _initialized = false;

  // Kích thước ảnh gốc
  static const imageWidth = 4096.0;
  static const imageHeight = 1920.0;
  static const imageAspectRatio = imageWidth / imageHeight;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Scale ảnh để cao bằng màn hình, rộng theo tỷ lệ gốc
    final finalHeight = screenSize.height;
    final finalWidth = finalHeight * imageAspectRatio;

    // Khởi tạo vị trí center
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPosition(screenSize, finalWidth, finalHeight);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: InteractiveViewer(
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
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
