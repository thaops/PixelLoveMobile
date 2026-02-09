import 'dart:io';
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
import 'package:pixel_love/core/widgets/app_back_icon.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/decorative_hearts.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/capture_animation_overlay.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/capture_button.dart';
import 'package:pixel_love/features/pet_image/presentation/models/capture_layout_metrics.dart';
import 'package:pixel_love/core/widgets/custom_loading_widget.dart';

class PetCaptureScreen extends ConsumerStatefulWidget {
  const PetCaptureScreen({super.key});

  @override
  ConsumerState<PetCaptureScreen> createState() => _PetCaptureScreenState();
}

class _PetCaptureScreenState extends ConsumerState<PetCaptureScreen> {
  bool _captureAnimationActive = false;
  final ImagePicker _imagePicker = ImagePicker();
  // Zoom mặc định khi vào màn hình
  double _zoomLevel = 1.0;
  // 🔥 Lưu notifier để tránh lỗi khi widget unmount
  PetCaptureNotifier? _captureNotifier;
  // 🔥 Track camera initialization để tránh màn hình đen
  bool _isCameraReady = false;
  // 🔥 Timestamp khi vào màn hình để đảm bảo loading hiển thị ít nhất 800ms
  DateTime? _screenEnterTime;
  // 🔥 Đếm số frame đã nhận để đảm bảo preview đã render
  int _frameCount = 0;

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
    // 🔥 Reset state khi vào màn hình
    _isCameraReady = false;
    _frameCount = 0;
    _screenEnterTime = DateTime.now();
    // 🔥 Lưu notifier reference để dùng an toàn trong callbacks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _captureNotifier = ref.read(petCaptureNotifierProvider.notifier);
        // 🔥 Force reset state khi vào màn hình để đảm bảo camera active
        _captureNotifier?.resetPreview();
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

    _captureNotifier = ref.read(petCaptureNotifierProvider.notifier);

    final canPop = !captureState.isFrozen && context.canPop();

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (captureState.isFrozen) {
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
              child: Stack(
                children: [
                  CameraAwesomeBuilder.custom(
                    saveConfig: SaveConfig.photo(),
                    imageAnalysisConfig: AnalysisConfig(
                      autoStart: true,
                      maxFramesPerSecond: 30,
                      androidOptions: AndroidAnalysisOptions.nv21(width: 720),
                    ),
                    onImageForAnalysis: (image) async {
                      _frameCount++;
                      if (!_isCameraReady && mounted && _frameCount >= 5) {
                        final elapsed = _screenEnterTime != null
                            ? DateTime.now()
                                  .difference(_screenEnterTime!)
                                  .inMilliseconds
                            : 0;
                        const minDelay = 800;
                        final remainingDelay = elapsed < minDelay
                            ? minDelay - elapsed
                            : 0;

                        if (remainingDelay > 0) {
                          Future.delayed(
                            Duration(milliseconds: remainingDelay),
                            () {
                              if (mounted) {
                                setState(() {
                                  _isCameraReady = true;
                                });
                              }
                            },
                          );
                        } else {
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted) {
                              setState(() {
                                _isCameraReady = true;
                              });
                            }
                          });
                        }
                      }
                      if (mounted && _captureNotifier != null) {
                        _captureNotifier!.onLiveFrame(image);
                      }
                    },
                    previewFit: CameraPreviewFit.contain,
                    previewAlignment: const Alignment(0, -0.5),
                    sensorConfig: SensorConfig.single(
                      sensor: Sensor.position(SensorPosition.back),
                      aspectRatio: CameraAspectRatios.ratio_1_1,
                      flashMode: FlashMode.none,
                    ),
                    builder: (cameraState, preview) {
                      final captureNotifier = ref.read(
                        petCaptureNotifierProvider.notifier,
                      );
                      captureNotifier.attachState(cameraState);
                      final metrics = CaptureLayoutMetrics(context);

                      return Stack(
                        children: [
                          PetPreviewMask(metrics: metrics),
                          if (captureState.isFrozen &&
                              captureState.frozenImage != null)
                            _FrozenPreviewOverlay(
                              image: captureState.frozenImage!,
                              metrics: metrics,
                              state: captureState,
                            ),
                          const DecorativeHearts(),
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
                          CaptureAnimationOverlay(
                            isActive: _captureAnimationActive,
                          ),
                        ],
                      );
                    },
                  ),

                  // 🔥 Khôi phục màn hình Splash loading (che camera khi đang khởi tạo)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: _isCameraReady ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: _isCameraReady,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AppColors.backgroundGradient,
                            ),
                          ),
                          child: const Center(
                            child: CustomLoadingWidget(
                              size: 120,
                              color: AppColors.primaryPink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget frozen preview overlay - dùng CustomPaint để che camera trong lỗ mask
class _FrozenPreviewOverlay extends StatelessWidget {
  const _FrozenPreviewOverlay({
    required this.image,
    required this.metrics,
    required this.state,
  });

  final ui.Image image;
  final CaptureLayoutMetrics metrics;
  final PetCaptureState state;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: FrozenMaskPainter(
          containerRect: metrics.previewRRect,
          image: image,
          rotation: state.sensorRotation,
          position: state.sensorPosition,
        ),
      ),
    );
  }
}

/// CustomPainter để vẽ frozen frame che camera trong lỗ mask
class FrozenMaskPainter extends CustomPainter {
  FrozenMaskPainter({
    required this.containerRect,
    required this.image,
    required this.rotation,
    required this.position,
  });

  final RRect containerRect;
  final ui.Image image;
  final int rotation;
  final SensorPosition position;

  @override
  void paint(Canvas canvas, Size size) {
    // 1️⃣ Vẽ background gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColors.backgroundGradient,
    );
    final bgPaint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2️⃣ Clip & Draw image (Tối ưu GPU)
    canvas.save();
    canvas.clipRRect(containerRect);

    final dst = containerRect.outerRect;
    final center = dst.center;

    // 🔥 Xoay canvas
    if (rotation != 0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation * 3.1415926535897932 / 180);
      canvas.translate(-center.dx, -center.dy);
    }

    // 🔥 Mirror nếu là camera trước
    if (position == SensorPosition.front) {
      canvas.translate(center.dx, center.dy);
      canvas.scale(-1, 1);
      canvas.translate(-center.dx, -center.dy);
    }

    final double imgW = image.width.toDouble();
    final double imgH = image.height.toDouble();

    // Luôn tính Src Rect dựa trên 1:1 ratio
    canvas.drawImageRect(
      image,
      _calculateSrcRect(imgW, imgH, 1.0),
      dst,
      Paint()..filterQuality = FilterQuality.high,
    );

    canvas.restore();
  }

  Rect _calculateSrcRect(double w, double h, double aspect) {
    // 🔥 Zoom rất nhẹ (1.06x) để cân đối bố cục
    const double zoom = 1.06;

    if (w / h > aspect) {
      final newH = h / zoom;
      final newW = newH * aspect;
      // Khớp với previewAlignment -0.5: dùng 0.22 (22%) để dịch chuyển vùng cắt lên trên
      final double offset = (w - newW) * 0.22;
      return Rect.fromLTWH((w - newW) / 2 - offset, (h - newH) / 2, newW, newH);
    } else {
      final newW = w / zoom;
      final newH = newW / aspect;
      // Khớp với previewAlignment -0.5: dịch vùng cắt lên trên
      final double offset = (h - newH) * 0.22;
      return Rect.fromLTWH((w - newW) / 2, (h - newH) / 2 - offset, newW, newH);
    }
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
    const double actionBarBottom = 0.0;

    return Stack(
      children: [
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
            onTap: () => context.go(AppRoutes.home),
            child: const AppBackIcon(),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 128),
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
            onTap: () async {
              if (state.isFrozen) {
                // 🔥 Điểu hướng NGAY LẬP TỨC
                notifier.send();
                context.push(AppRoutes.petAlbumSwipe).then((_) {
                  if (context.mounted) {
                    notifier.resetPreview();
                  }
                });
              } else {
                onCapture();
              }
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
