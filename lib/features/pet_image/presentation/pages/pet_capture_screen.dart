import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_preview_mask.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/decorative_hearts.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/capture_animation_overlay.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/capture_button.dart';
import 'package:pixel_love/features/pet_image/presentation/models/capture_layout_metrics.dart';

class PetCaptureScreen extends ConsumerStatefulWidget {
  const PetCaptureScreen({super.key});

  @override
  ConsumerState<PetCaptureScreen> createState() => _PetCaptureScreenState();
}

class _PetCaptureScreenState extends ConsumerState<PetCaptureScreen> {
  bool _captureAnimationActive = false;
  bool _wasSending = false;
  final ImagePicker _imagePicker = ImagePicker();
  // Zoom mặc định khi vào màn hình
  double _zoomLevel = 1.0;
  // 🔥 Lưu notifier để tránh lỗi khi widget unmount
  PetCaptureNotifier? _captureNotifier;

  void _triggerCaptureAnimation() {
    setState(() => _captureAnimationActive = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _captureAnimationActive = false);
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
        notifier.setPreviewFile(file);
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  void initState() {
    super.initState();
    // 🔥 Lưu notifier reference để dùng an toàn trong callbacks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _captureNotifier = ref.read(petCaptureNotifierProvider.notifier);
      }
    });
  }

  @override
  void dispose() {
    // 🔥 Clear reference để tránh sử dụng sau khi dispose
    _captureNotifier = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(petCaptureNotifierProvider);

    // 🔥 Cập nhật notifier reference mỗi lần build để đảm bảo luôn có giá trị mới nhất
    _captureNotifier = ref.read(petCaptureNotifierProvider.notifier);

    ref.listen<PetCaptureState?>(petCaptureNotifierProvider, (previous, next) {
      if (_wasSending &&
          next != null &&
          !next.isSending &&
          previous?.isFrozen == true &&
          !next.isFrozen) {
        if (mounted) {
          context.push(AppRoutes.petAlbum);
        }
      }
      _wasSending = next?.isSending ?? false;
    });
    // Cho phép back khi chưa freeze
    final canPop = !captureState.isFrozen && context.canPop();

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (captureState.isFrozen) {
            // Reset khi đã freeze
            ref.read(petCaptureNotifierProvider.notifier).resetPreview();
          } else if (!context.canPop()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.mounted) {
                context.go(AppRoutes.home);
              }
            });
          }
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.backgroundGradient,
              ),
            ),
            child: SafeArea(
              child: CameraAwesomeBuilder.custom(
                saveConfig: SaveConfig.photo(),
                imageAnalysisConfig: AnalysisConfig(
                  autoStart: true,
                  maxFramesPerSecond: 30,
                  androidOptions: AndroidAnalysisOptions.nv21(
                    width: 320, // 🔥 320 là sweet spot - giảm khựng khi freeze
                  ),
                ),
                onImageForAnalysis: (image) async {
                  // 🔥 Kiểm tra mounted và notifier trước khi sử dụng
                  if (mounted && _captureNotifier != null) {
                    _captureNotifier!.onLiveFrame(image);
                  }
                },
                previewFit: CameraPreviewFit.contain,
                previewAlignment: const Alignment(0, -0.49),
                sensorConfig: SensorConfig.single(
                  sensor: Sensor.position(SensorPosition.back),
                  aspectRatio: CameraAspectRatios.ratio_4_3,
                  flashMode: FlashMode.none,
                ),
                builder: (cameraState, preview) {
                  final captureNotifier = ref.read(
                    petCaptureNotifierProvider.notifier,
                  );
                  captureNotifier.attachState(cameraState);

                  // 🔥 Tính metrics một lần duy nhất
                  final metrics = CaptureLayoutMetrics(context);

                  return Stack(
                    children: [
                      // 🔥 1. Camera preview (LUÔN CÓ) - preview đã được render bởi CameraAwesome
                      // Không cần thêm preview vào metricsStack vì CameraAwesome đã render nó

                      // 🔥 2. Mask overlay (LUÔN CÓ) - dùng metrics chung
                      PetPreviewMask(metrics: metrics),

                      // 🔥 3. Frozen mask painter (CHỈ KHI FROZEN) - CHE CAMERA TRONG LỖ
                      if (captureState.isFrozen && captureState.bytes != null)
                        _FrozenPreviewOverlay(
                          bytes: captureState.bytes!,
                          metrics: metrics,
                        ),

                      // 🔥 4. Decorative hearts
                      const DecorativeHearts(),

                      // 🔥 5. Overlay UI (LUÔN CÓ - chỉ đổi opacity/enabled)
                      _UnifiedOverlayUI(
                        state: captureState,
                        notifier: captureNotifier,
                        zoomLevel: _zoomLevel,
                        metrics: metrics,
                        onPickFromGallery: _pickFromGallery,
                        onCapture: () async {
                          _triggerCaptureAnimation();
                          await captureNotifier.freezeFromLiveFrame();
                        },
                      ),

                      // // // 🔥 6. Capture animation
                      CaptureAnimationOverlay(
                        isActive: _captureAnimationActive,
                      ),

                      // 🔥 7. Input blocker khi đang capture
                      // if (captureState.isCapturing)
                      //   Positioned.fill(
                      //     child: IgnorePointer(
                      //       child: Container(color: Colors.transparent),
                      //     ),
                      //   ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget frozen preview overlay - dùng CustomPaint để che camera trong lỗ mask
class _FrozenPreviewOverlay extends StatefulWidget {
  const _FrozenPreviewOverlay({required this.bytes, required this.metrics});

  final Uint8List bytes;
  final CaptureLayoutMetrics metrics;

  @override
  State<_FrozenPreviewOverlay> createState() => _FrozenPreviewOverlayState();
}

class _FrozenPreviewOverlayState extends State<_FrozenPreviewOverlay> {
  ui.Image? _decodedImage;

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  Future<void> _decodeImage() async {
    final codec = await ui.instantiateImageCodec(widget.bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _decodedImage = frame.image;
      });
    }
  }

  @override
  void dispose() {
    _decodedImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_decodedImage == null) {
      return const SizedBox.shrink();
    }

    // 🔥 Dùng metrics chung - không tính lại
    return Positioned.fill(
      child: CustomPaint(
        painter: FrozenMaskPainter(
          containerRect: widget.metrics.previewRRect,
          image: _decodedImage!,
        ),
      ),
    );
  }
}

/// CustomPainter để vẽ frozen frame che camera trong lỗ mask
class FrozenMaskPainter extends CustomPainter {
  FrozenMaskPainter({required this.containerRect, required this.image});

  final RRect containerRect;
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    // 1️⃣ Vẽ background gradient (giữ nguyên UI)
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColors.backgroundGradient,
    );
    final bgPaint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2️⃣ Clip đúng khung (rounded rectangle)
    canvas.save();
    canvas.clipRRect(containerRect);

    // 3️⃣ Vẽ frozen frame → CHE camera preview trong lỗ
    final dst = containerRect.outerRect;

    // 🔥 Crop đúng aspect ratio như preview (CỰC QUAN TRỌNG)
    final previewAspect = dst.width / dst.height;
    final imageAspect = image.width / image.height;

    late Rect src;

    if (imageAspect > previewAspect) {
      // Image rộng hơn preview → crop 2 bên
      final newWidth = image.height * previewAspect;
      final x = (image.width - newWidth) / 2;
      src = Rect.fromLTWH(x, 0, newWidth, image.height.toDouble());
    } else {
      // Image cao hơn preview → crop trên dưới
      final newHeight = image.width / previewAspect;
      final y = (image.height - newHeight) / 2;
      src = Rect.fromLTWH(0, y, image.width.toDouble(), newHeight);
    }

    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FrozenMaskPainter old) {
    return old.containerRect != containerRect || old.image != image;
  }
}

/// Widget overlay UI thống nhất - dùng absolute positioning, không Column+Expanded
class _UnifiedOverlayUI extends StatelessWidget {
  const _UnifiedOverlayUI({
    required this.state,
    required this.notifier,
    required this.zoomLevel,
    required this.metrics,
    required this.onPickFromGallery,
    required this.onCapture,
  });

  final PetCaptureState state;
  final PetCaptureNotifier notifier;
  final double zoomLevel;
  final CaptureLayoutMetrics metrics;
  final VoidCallback onPickFromGallery;
  final Future<void> Function() onCapture;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // 🔥 Tính vị trí absolute cho action bar (từ bottom)
    final actionBarBottom = keyboardHeight > 0 ? keyboardHeight : 0.0;

    return Stack(
      children: [
        // 🔥 Header (luôn có, chỉ đổi opacity khi frozen)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: state.isFrozen ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: state.isFrozen,
              child: _HeaderSection(
                state: state,
                notifier: notifier,
                zoomLevel: zoomLevel,
              ),
            ),
          ),
        ),

        // 🔥 Action bar (luôn có, vị trí cố định từ bottom)
        Positioned(
          bottom: actionBarBottom,
          left: 0,
          right: 0,
          child: _ActionBarSection(
            state: state,
            notifier: notifier,
            onPickFromGallery: onPickFromGallery,
            onCapture: onCapture,
          ),
        ),

        // 🔥 Caption input (luôn có, chỉ đổi opacity khi không frozen)
        Positioned(
          bottom:
              actionBarBottom + 360.0, // 🔥 Vị trí cố định phía trên action bar
          left: 16,
          right: 16,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: state.isFrozen ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !state.isFrozen,
              child: _CaptionSection(notifier: notifier),
            ),
          ),
        ),

        // 🔥 Close button (luôn có, chỉ đổi opacity khi không frozen)
        Positioned(
          top: 12,
          left: 12,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: state.isFrozen ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !state.isFrozen,
              child: GestureDetector(
                onTap: notifier.resetPreview,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Header section
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.state,
    required this.notifier,
    required this.zoomLevel,
  });

  final PetCaptureState state;
  final PetCaptureNotifier notifier;
  final double zoomLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: notifier.toggleFlash,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPink.withOpacity(0.05),
                border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                _flashIcon(state.flashMode),
                color: AppColors.primaryPink,
                size: 24,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryPink.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              '${zoomLevel.toStringAsFixed(1)}x',
              style: const TextStyle(
                color: AppColors.primaryPink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

/// Action bar section
class _ActionBarSection extends StatelessWidget {
  const _ActionBarSection({
    required this.state,
    required this.notifier,
    required this.onPickFromGallery,
    required this.onCapture,
  });

  final PetCaptureState state;
  final PetCaptureNotifier notifier;
  final VoidCallback onPickFromGallery;
  final Future<void> Function() onCapture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gallery button (ẩn khi frozen)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: state.isFrozen ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: state.isFrozen,
              child: GestureDetector(
                onTap: onPickFromGallery,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryPink.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.primaryPink.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primaryPink,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Capture button (tự đổi icon bên trong)
          CaptureButton(
            state: state,
            onTap: state.isFrozen
                ? notifier.send
                : () async {
                    await onCapture();
                  },
          ),

          // Switch camera button (ẩn khi frozen)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: state.isFrozen ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: state.isFrozen,
              child: GestureDetector(
                onTap: notifier.switchCamera,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryPink.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.primaryPink.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.cameraswitch_rounded,
                    color: AppColors.primaryPink,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Caption section
class _CaptionSection extends StatefulWidget {
  const _CaptionSection({required this.notifier});

  final PetCaptureNotifier notifier;

  @override
  State<_CaptionSection> createState() => _CaptionSectionState();
}

class _CaptionSectionState extends State<_CaptionSection> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.notifier.captionController.text.isNotEmpty;
    final isFocused = _focusNode.hasFocus;
    final showHint = !isFocused && !hasText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: widget.notifier.captionController,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
        cursorColor: AppColors.primaryPink,
        maxLines: 1,
        maxLength: 60,
        onChanged: (_) => setState(() {}),
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
    );
  }
}
