import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';

class PetCaptureScreen extends ConsumerStatefulWidget {
  const PetCaptureScreen({super.key});

  @override
  ConsumerState<PetCaptureScreen> createState() => _PetCaptureScreenState();
}

class _PetCaptureScreenState extends ConsumerState<PetCaptureScreen> {
  bool _flashOverlay = false;
  bool _wasSending = false;
  final ImagePicker _imagePicker = ImagePicker();
  double _zoomLevel = 1.0;

  void _triggerFlashOverlay() {
    setState(() => _flashOverlay = true);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _flashOverlay = false);
      }
    });
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        final file = File(image.path);
        final notifier = ref.read(petCaptureNotifierProvider.notifier);
        // Set preview file directly
        notifier.setPreviewFile(file);
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(petCaptureNotifierProvider);

    // Listen for successful send completion
    ref.listen(petCaptureNotifierProvider, (previous, next) {
      // Check if sending just completed (was sending, now not sending, and not in preview mode)
      if (_wasSending && !next.isSending && !next.isPreviewMode) {
        // Navigate to album after successful send
        // Use push instead of go to maintain navigation stack
        if (mounted) {
          context.push(AppRoutes.petAlbum);
        }
      }
      _wasSending = next.isSending;
    });
    final canPop = !captureState.isPreviewMode && context.canPop();

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (captureState.isPreviewMode) {
            // If in preview mode, reset preview instead of popping
            ref.read(petCaptureNotifierProvider.notifier).resetPreview();
          } else if (!context.canPop()) {
            // If cannot pop, navigate to home instead of exiting app
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.mounted) {
                context.go(AppRoutes.home);
              }
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: CameraAwesomeBuilder.custom(
            saveConfig: SaveConfig.photo(
              // Giảm độ phân giải capture để tránh crash
              // Resolution sẽ được tự động scale xuống mức hợp lý
            ),
            previewFit: CameraPreviewFit.cover,
            // Cấu hình sensor để giảm độ phân giải preview, tránh crash camera
            sensorConfig: SensorConfig.single(
              sensor: Sensor.position(SensorPosition.back),
              aspectRatio: CameraAspectRatios.ratio_4_3,
              flashMode: FlashMode.auto,
            ),
            builder: (cameraState, preview) {
              final captureNotifier = ref.read(
                petCaptureNotifierProvider.notifier,
              );
              captureNotifier.attachState(cameraState);

              // Debug: Kiểm tra preview type
              debugPrint('🔍 Preview type: ${preview.runtimeType}');
              debugPrint('🔍 Preview is Widget: ${preview is Widget}');
              if (preview is! Widget) {
                debugPrint('🔍 Preview toString: ${preview.toString()}');
              }

              return Stack(
                children: [
                  // Mask để che phần preview ngoài container
                  // Tạo hiệu ứng "cửa sổ" để chỉ hiển thị preview trong container
                  _buildPreviewMask(),

                  Column(
                    children: [
                      // Header mới với Flash và Zoom
                      if (!captureState.isPreviewMode)
                        _buildNewHeader(captureState, captureNotifier),

                      // Camera preview container
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Center(
                            child: _buildCameraContainer(
                              cameraState,
                              preview,
                              captureState,
                              captureNotifier,
                            ),
                          ),
                        ),
                      ),

                      // Action bar: Gallery (trái), Shutter (giữa), Switch camera (phải)
                      _buildActionBar(captureState, captureNotifier),

                      // Footer với "Lịch sử"
                      if (!captureState.isPreviewMode) _buildFooter(),
                    ],
                  ),

                  // Loading overlay khi gửi
                  if (captureState.isSending) _buildSendingOverlay(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCameraContainer(
    CameraState cameraState,
    Object preview,
    PetCaptureState captureState,
    PetCaptureNotifier captureNotifier,
  ) {
    // Tính toán kích thước container với aspect ratio 4:3
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.9; // 90% chiều rộng màn hình
    final containerHeight = containerWidth * 4 / 3; // Aspect ratio 4:3

    // Xử lý preview
    Widget previewWidget;
    if (captureState.isPreviewMode && captureState.previewFile != null) {
      previewWidget = _buildPreview(captureState.previewFile!);
    } else {
      // Preview là AnalysisPreview, không phải Widget
      // CameraAwesome đã render preview ở background layer
      // Chúng ta chỉ cần một container trong suốt để giữ layout
      // Preview sẽ hiển thị từ background
      previewWidget = Container(
        color: Colors.transparent,
        // Preview được render bởi CameraAwesomeBuilder ở background layer
      );
    }

    return Container(
      width: containerWidth,
      height: containerHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors
            .transparent, // Trong suốt để preview hiển thị qua từ background
      ),
      // Không dùng ClipRRect để tránh lỗi Texture bị đen
      child: Stack(
        children: [
          // Preview image nếu ở preview mode
          if (captureState.isPreviewMode && captureState.previewFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: previewWidget,
            ),

          // Flash overlay
          if (_flashOverlay)
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.35)),
            ),

          // Text input xuất hiện sau khi chụp
          _buildCaptionFieldOnPreview(captureState, captureNotifier),

          // Nút gửi (chỉ hiển thị khi đã chụp)
          _buildSendButtonOnPreview(captureState, captureNotifier),

          // Nút đóng preview
          _buildClosePreviewButtonOnPreview(captureState, captureNotifier),
        ],
      ),
    );
  }

  Widget _buildPreviewMask() {
    // Tính toán vị trí và kích thước container
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth * 0.9;
    final containerHeight = containerWidth * 4 / 3;
    final containerLeft = (screenWidth - containerWidth) / 2;

    // Tính toán vị trí container dựa trên layout Column
    final captureState = ref.watch(petCaptureNotifierProvider);
    final headerHeight = captureState.isPreviewMode
        ? 0.0
        : 50.0; // Header mới nhỏ hơn
    final footerHeight = captureState.isPreviewMode ? 0.0 : 60.0;
    final actionBarHeight = 120.0;
    final cameraPaddingBottom = 24.0; // Padding bottom của camera container

    // Tính toán vị trí container trong Column layout
    final availableHeight =
        screenHeight - headerHeight - actionBarHeight - footerHeight;
    // Trừ padding bottom khi tính toán vị trí center
    final containerTop =
        headerHeight +
        (availableHeight - containerHeight - cameraPaddingBottom) / 2;

    // Sử dụng CustomPaint để tạo mask che phần preview ngoài container
    // với bo góc tròn chính xác
    return Positioned.fill(
      child: CustomPaint(
        painter: _PreviewMaskPainter(
          containerRect: RRect.fromRectAndRadius(
            Rect.fromLTWH(
              containerLeft,
              containerTop,
              containerWidth,
              containerHeight,
            ),
            const Radius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(File file) {
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildNewHeader(PetCaptureState state, PetCaptureNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flash icon (trái)
          GestureDetector(
            onTap: notifier.toggleFlash,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Icon(
                _flashIcon(state.flashMode),
                color: state.flashMode == FlashMode.none
                    ? Colors.white.withOpacity(0.5)
                    : AppColors.primaryPink,
                size: 24,
              ),
            ),
          ),
          // Zoom indicator (phải)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_zoomLevel.toInt()}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(PetCaptureState state, PetCaptureNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gallery icon (trái)
          GestureDetector(
            onTap: state.isPreviewMode ? null : _pickFromGallery,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.photo_library_rounded,
                color: state.isPreviewMode
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white,
                size: 24,
              ),
            ),
          ),
          // Shutter button (giữa) - Viền vàng, lõi trắng
          GestureDetector(
            onTap: state.isPreviewMode
                ? null
                : () async {
                    _triggerFlashOverlay();
                    await notifier.capturePhoto();
                  },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryPink, width: 5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Switch camera icon (phải)
          GestureDetector(
            onTap: state.isPreviewMode ? null : notifier.switchCamera,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.cameraswitch_rounded,
                color: state.isPreviewMode
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButtonOnPreview(
    PetCaptureState state,
    PetCaptureNotifier notifier,
  ) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      bottom: state.isPreviewMode ? 16 : -100,
      right: 16,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: state.isPreviewMode ? 1 : 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryPink,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPink.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: state.isPreviewMode && !state.isSending
                  ? notifier.send
                  : null,
              child: const Center(
                child: Icon(Icons.send_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptionFieldOnPreview(
    PetCaptureState state,
    PetCaptureNotifier notifier,
  ) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      left: 16,
      right: 80, // Tránh nút send
      bottom: state.isPreviewMode ? 16 : -120,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        opacity: state.isPreviewMode ? 1 : 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: TextField(
            controller: notifier.captionController,
            style: const TextStyle(color: Colors.white),
            cursorColor: AppColors.primaryPink,
            maxLines: 1,
            maxLength: 60,
            decoration: const InputDecoration(
              isDense: true,
              counterText: '',
              border: InputBorder.none,
              hintText: 'Đang nghĩ gì?',
              hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(60)],
          ),
        ),
      ),
    );
  }

  Widget _buildClosePreviewButtonOnPreview(
    PetCaptureState state,
    PetCaptureNotifier notifier,
  ) {
    if (!state.isPreviewMode) return const SizedBox.shrink();
    return Positioned(
      top: 12,
      left: 12,
      child: GestureDetector(
        onTap: notifier.resetPreview,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.6),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return GestureDetector(
      onTap: () {
        // Navigate to history/album
        context.push(AppRoutes.petAlbum);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_arrow_up_rounded,
              color: AppColors.primaryPink.withOpacity(0.9),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              'Lịch sử',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  IconData _flashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.none:
        return Icons.flash_off_rounded;
      default:
        return Icons.flash_auto_rounded;
    }
  }
}

/// Custom Painter để tạo mask che phần preview ngoài container với bo góc tròn
class _PreviewMaskPainter extends CustomPainter {
  final RRect containerRect;

  _PreviewMaskPainter({required this.containerRect});

  @override
  void paint(Canvas canvas, Size size) {
    // Tạo path che toàn bộ màn hình trừ phần container
    final maskPath = Path()
      // Thêm hình chữ nhật che toàn bộ màn hình
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      // Trừ đi phần container (tạo lỗ để preview hiển thị qua)
      ..addRRect(containerRect)
      ..fillType = PathFillType.evenOdd;

    // Vẽ mask màu đen
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawPath(maskPath, paint);
  }

  @override
  bool shouldRepaint(_PreviewMaskPainter oldDelegate) {
    return oldDelegate.containerRect != containerRect;
  }
}
