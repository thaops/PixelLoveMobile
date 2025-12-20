import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';

class PetCaptureScreen extends ConsumerStatefulWidget {
  const PetCaptureScreen({super.key});

  @override
  ConsumerState<PetCaptureScreen> createState() => _PetCaptureScreenState();
}

class _PetCaptureScreenState extends ConsumerState<PetCaptureScreen> {
  bool _flashOverlay = false;

  void _triggerFlashOverlay() {
    setState(() => _flashOverlay = true);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _flashOverlay = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CameraAwesomeBuilder.custom(
          saveConfig: SaveConfig.photo(),
          previewFit: CameraPreviewFit.cover,
          builder: (cameraState, _) {
            final captureNotifier = ref.read(petCaptureNotifierProvider.notifier);
            captureNotifier.attachState(cameraState);
            
            final captureState = ref.watch(petCaptureNotifierProvider);
            
            return Stack(
              children: [
                // Ảnh vừa chụp (overlay) khi ở preview mode
                if (captureState.isPreviewMode &&
                    captureState.previewFile != null)
                  Positioned.fill(
                    child: _buildPreview(captureState.previewFile!),
                  ),

                // Flash overlay
                if (_flashOverlay)
                  Positioned.fill(
                    child: Container(color: Colors.white.withOpacity(0.35)),
                  ),

                // Nút flash & chuyển camera
                _buildTopControls(captureState, captureNotifier),

                // Text input xuất hiện sau khi chụp
                _buildCaptionField(captureState, captureNotifier),

                // Nút chụp
                _buildShutterButton(captureState, captureNotifier),

                // Nút gửi (chỉ hiển thị khi đã chụp)
                _buildSendButton(captureState, captureNotifier),

                // Nút đóng preview
                _buildClosePreviewButton(captureState, captureNotifier),

                // Loading overlay khi gửi
                if (captureState.isSending) _buildSendingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPreview(File file) {
    return Container(
      color: Colors.black,
      child: Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildTopControls(PetCaptureState state, PetCaptureNotifier notifier) {
    final iconColor = Colors.white.withOpacity(0.9);
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flash
          _ControlIcon(
            icon: _flashIcon(state.flashMode),
            onTap: state.isPreviewMode ? null : notifier.toggleFlash,
            color: iconColor,
          ),
          // Đổi camera
          _ControlIcon(
            icon: Icons.cameraswitch_rounded,
            onTap: state.isPreviewMode ? null : notifier.switchCamera,
            color: iconColor,
          ),
        ],
      ),
    );
  }

  Widget _buildShutterButton(PetCaptureState state, PetCaptureNotifier notifier) {
    return Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Center(
          child: GestureDetector(
            onTap: state.isPreviewMode
                ? null
                : () async {
                    _triggerFlashOverlay();
                    await notifier.capturePhoto();
                  },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: Colors.white.withOpacity(0.08),
              ),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(PetCaptureState state, PetCaptureNotifier notifier) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      bottom: state.isPreviewMode ? 42 : -100,
      right: 28,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: state.isPreviewMode ? 1 : 0,
        child: SafeArea(
          top: false,
          child: FloatingActionButton(
            heroTag: 'send-btn',
            backgroundColor: AppColors.primaryPink,
            onPressed: state.isPreviewMode && !state.isSending
                ? notifier.send
                : null,
            child: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptionField(PetCaptureState state, PetCaptureNotifier notifier) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      left: 20,
      right: 20,
      bottom: state.isPreviewMode ? 130 : -120,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        opacity: state.isPreviewMode ? 1 : 0,
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
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
      ),
    );
  }

  Widget _buildClosePreviewButton(PetCaptureState state, PetCaptureNotifier notifier) {
    if (!state.isPreviewMode) return const SizedBox.shrink();
    return Positioned(
      top: 32,
      left: 20,
      child: SafeArea(
        child: GestureDetector(
          onTap: notifier.resetPreview,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.4),
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildSendingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
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

class _ControlIcon extends StatelessWidget {
  const _ControlIcon({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.35),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
