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
            saveConfig: SaveConfig.photo(),
            previewFit: CameraPreviewFit.cover,
            builder: (cameraState, preview) {
              final captureNotifier = ref.read(
                petCaptureNotifierProvider.notifier,
              );
              captureNotifier.attachState(cameraState);

              return Stack(
                children: [
                  Column(
                    children: [
                      // Header với Avatar, Audience, Menu
                      if (!captureState.isPreviewMode) _buildHeader(),

                      // Camera preview container
                      Expanded(
                        child: Center(
                          child: _buildCameraContainer(
                            preview,
                            captureState,
                            captureNotifier,
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
    Object preview,
    PetCaptureState captureState,
    PetCaptureNotifier captureNotifier,
  ) {
    // Tính toán kích thước container với aspect ratio 4:3
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.9; // 90% chiều rộng màn hình
    final containerHeight = containerWidth * 4 / 3; // Aspect ratio 4:3

    // Preview trả về từ CameraAwesome có thể là AnalysisPreview, không phải Widget.
    // Cố gắng lấy widget bên trong, fallback SizedBox nếu không có.
    final previewWidget = preview is Widget
        ? preview
        : (preview as dynamic).widget as Widget? ?? const SizedBox.shrink();

    return Container(
      width: containerWidth,
      height: containerHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Camera preview hoặc preview image
            if (captureState.isPreviewMode && captureState.previewFile != null)
              _buildPreview(captureState.previewFile!)
            else
              // Camera preview từ CameraAwesome (builder cung cấp)
              SizedBox.expand(child: previewWidget),

            // Flash overlay
            if (_flashOverlay)
              Positioned.fill(
                child: Container(color: Colors.white.withOpacity(0.35)),
              ),

            // Controls trên camera: Flash (trái), Zoom (phải)
            if (!captureState.isPreviewMode)
              _buildCameraControlsOnPreview(captureState, captureNotifier),

            // Text input xuất hiện sau khi chụp
            _buildCaptionFieldOnPreview(captureState, captureNotifier),

            // Nút gửi (chỉ hiển thị khi đã chụp)
            _buildSendButtonOnPreview(captureState, captureNotifier),

            // Nút đóng preview
            _buildClosePreviewButtonOnPreview(captureState, captureNotifier),
          ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              // Navigate to profile or settings
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryPink, width: 2),
                color: Colors.white.withOpacity(0.2),
              ),
              child: ClipOval(
                child: Container(
                  color: AppColors.primaryPink.withOpacity(0.3),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Audience label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryPink.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  color: AppColors.primaryPink,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '4 người bạn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Menu icon
          GestureDetector(
            onTap: () {
              // Show audience selection or settings
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.4),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControlsOnPreview(
    PetCaptureState state,
    PetCaptureNotifier notifier,
  ) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
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
                border: Border.all(color: Colors.amber.shade400, width: 5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
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
