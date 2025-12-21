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
  final FocusNode _captionFocusNode = FocusNode();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _captionFocusNode.addListener(_onCaptionFocusChange);
  }

  @override
  void dispose() {
    _captionFocusNode.removeListener(_onCaptionFocusChange);
    _captionFocusNode.dispose();
    super.dispose();
  }

  void _onCaptionFocusChange() {
    final isFocused = _captionFocusNode.hasFocus;
    if (_isKeyboardVisible != isFocused) {
      setState(() {
        _isKeyboardVisible = isFocused;
      });
    } else {
      // Trigger rebuild để ẩn/hiện hint text
      setState(() {});
    }
  }

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
        resizeToAvoidBottomInset: false, // Tránh resize khi bàn phím hiện lên
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
                  // Overlay đen che toàn bộ màn hình khi ở preview mode để ẩn camera
                  if (captureState.isPreviewMode)
                    Positioned.fill(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        opacity: 1.0,
                        child: Container(color: Colors.black),
                      ),
                    ),

                  // Mask để che phần preview ngoài container (chỉ khi không ở preview mode)
                  if (!captureState.isPreviewMode) _buildPreviewMask(),

                  Column(
                    children: [
                      // Header mới với Flash và Zoom
                      if (!captureState.isPreviewMode)
                        _buildNewHeader(captureState, captureNotifier)
                      else
                        // Spacer để giữ vị trí ảnh preview giống như khi có header
                        // Header có padding vertical 12, icon size 24 + padding 8*2 = 40, tổng ~64
                        const SizedBox(height: 0),

                      // Camera preview container
                      Expanded(
                        child: _buildPreviewContainer(
                          cameraState,
                          preview,
                          captureState,
                          captureNotifier,
                        ),
                      ),

                      // Action bar: Gallery (trái), Shutter (giữa), Switch camera (phải)
                      // Chỉ hiển thị trong Column khi ở camera mode
                      if (!captureState.isPreviewMode)
                        _buildActionBar(captureState, captureNotifier)
                      else
                        // Spacer để giữ vị trí ảnh preview giống như khi có action bar
                        const SizedBox(height: 120),

                      // Footer với "Lịch sử"
                      if (!captureState.isPreviewMode) _buildFooter(),
                    ],
                  ),

                  // Action bar: Gallery (trái), Shutter (giữa), Switch camera (phải)
                  // Đặt bằng Positioned khi ở preview mode để giữ vị trí cố định
                  if (captureState.isPreviewMode)
                    _buildActionBarPositioned(captureState, captureNotifier),

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

          // Nút đóng preview
          _buildClosePreviewButtonOnPreview(captureState, captureNotifier),
        ],
      ),
    );
  }

  Widget _buildPreviewContainer(
    CameraState cameraState,
    Object preview,
    PetCaptureState captureState,
    PetCaptureNotifier captureNotifier,
  ) {
    // Lấy chiều cao bàn phím để đẩy ảnh preview lên khi bàn phím hiện
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Chỉ đẩy lên khi ở preview mode và có bàn phím
    final bottomPadding = captureState.isPreviewMode && keyboardHeight > 0
        ? keyboardHeight *
              0.8 // Đẩy lên 30% chiều cao bàn phím
        : 0.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      padding: EdgeInsets.only(bottom: 30 + bottomPadding),
      child: Center(
        child: _buildCameraContainer(
          cameraState,
          preview,
          captureState,
          captureNotifier,
        ),
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
    final cameraPaddingBottom = 62.0; // Padding bottom của camera container

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

  Widget _buildActionBarPositioned(
    PetCaptureState state,
    PetCaptureNotifier notifier,
  ) {
    // Lấy chiều cao bàn phím để đẩy action bar lên khi bàn phím hiện
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Tính toán vị trí bottom cố định: footer height (60)
    // Vị trí này giống như khi action bar nằm trong Column với footer
    final footerHeight = state.isPreviewMode ? 60.0 : 0.0;
    // Khi bàn phím hiện, chỉ đẩy action bar lên một phần nhỏ (30%) để không che text field
    // Ảnh preview đã đẩy lên nhiều nên action bar chỉ cần đẩy lên ít
    final bottomPosition =
        footerHeight +
        (keyboardHeight > 0
            ? keyboardHeight * 0.73
            : 0); // Chỉ đẩy lên 30% chiều cao bàn phím

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      left: 0,
      right: 0,
      bottom: bottomPosition,
      child: _buildActionBarContent(state, notifier),
    );
  }

  Widget _buildActionBar(PetCaptureState state, PetCaptureNotifier notifier) {
    // Lấy chiều cao bàn phím để đẩy action bar lên khi bàn phím hiện
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? keyboardHeight : 0),
      child: _buildActionBarContent(state, notifier),
    );
  }

  Widget _buildActionBarContent(
    PetCaptureState state,
    PetCaptureNotifier notifier,
  ) {
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
          // Shutter button (giữa) - Chuyển thành icon gửi khi ở preview mode
          GestureDetector(
            onTap: state.isPreviewMode
                ? (state.isSending ? null : notifier.send)
                : () async {
                    _triggerFlashOverlay();
                    await notifier.capturePhoto();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: state.isPreviewMode
                      ? AppColors.primaryPink
                      : AppColors.primaryPink,
                  width: 5,
                ),
                color: state.isPreviewMode
                    ? AppColors.primaryPink
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: state.isPreviewMode
                    ? Icon(
                        Icons.send_rounded,
                        key: const ValueKey('send'),
                        color: Colors.white,
                        size: 32,
                      )
                    : Container(
                        key: const ValueKey('shutter'),
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
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

  Widget _buildCaptionFieldOnPreview(
    PetCaptureState state,
    PetCaptureNotifier notifier,
  ) {
    // Text field đứng yên, không bị đẩy lên khi bàn phím hiện
    final bottomPosition = state.isPreviewMode ? 60.0 : -120.0;
    // Ẩn hint text khi text field được focus hoặc có text
    final hasText = notifier.captionController.text.isNotEmpty;
    final isFocused = _captionFocusNode.hasFocus;
    final showHint = !isFocused && !hasText;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      left: 16,
      right: 16,
      bottom: bottomPosition,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        opacity: state.isPreviewMode ? 1 : 0,
        child: TextField(
          controller: notifier.captionController,
          focusNode: _captionFocusNode,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
          cursorColor: AppColors.primaryPink,
          maxLines: 1,
          maxLength: 60,
          onChanged: (_) =>
              setState(() {}), // Trigger rebuild khi text thay đổi
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            border: InputBorder.none,
            hintText: showHint ? 'Đang nghĩ gì?' : '',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(60)],
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
