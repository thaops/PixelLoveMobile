import 'dart:io';
import 'dart:ui';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_preview_mask.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_capture_action_bar.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_capture_footer.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_capture_header.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_capture_sending_overlay.dart';

class PetCaptureScreen extends ConsumerStatefulWidget {
  const PetCaptureScreen({super.key});

  @override
  ConsumerState<PetCaptureScreen> createState() => _PetCaptureScreenState();
}

class _PetCaptureScreenState extends ConsumerState<PetCaptureScreen> {
  bool _flashOverlay = false;
  bool _wasSending = false;
  final ImagePicker _imagePicker = ImagePicker();
  // Zoom mặc định khi vào màn hình
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

  List<Widget> _buildDecorativeHearts() {
    return [
      Positioned(
        bottom: 100,
        left: 30,
        child: Icon(
          Icons.favorite,
          size: 50,
          color: AppColors.iconPurple.withOpacity(0.3),
        ),
      ),
      Positioned(
        bottom: 180,
        right: 40,
        child: Icon(
          Icons.favorite_border,
          size: 45,
          color: AppColors.iconPurple.withOpacity(0.25),
        ),
      ),
      Positioned(
        bottom: 750,
        left: 60,
        child: Icon(
          Icons.favorite,
          size: 40,
          color: AppColors.iconPurple.withOpacity(0.2),
        ),
      ),
    ];
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
  Widget build(BuildContext context) {
    final captureState = ref.watch(petCaptureNotifierProvider);

    ref.listen<PetCaptureState?>(petCaptureNotifierProvider, (previous, next) {
      if (_wasSending &&
          next != null &&
          !next.isSending &&
          !next.isPreviewMode) {
        if (mounted) {
          context.push(AppRoutes.petAlbum);
        }
      }
      _wasSending = next?.isSending ?? false;
    });
    final canPop = !captureState.isPreviewMode && context.canPop();

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (captureState.isPreviewMode) {
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
                // Đổi từ cover sang contain để preview không crop quá nhiều
                // Giúp preview (x1) khớp với ảnh thật khi review (x1)
                previewFit: CameraPreviewFit.contain,
                previewAlignment: const Alignment(
                  0,
                  -0.55,
                ), // Top center nhưng cách top một chút
                sensorConfig: SensorConfig.single(
                  sensor: Sensor.position(SensorPosition.back),
                  // Dùng 4:3 để gần với tỉ lệ khung preview (4/3.5 ≈ 1.143)
                  aspectRatio: CameraAspectRatios.ratio_4_3,
                  flashMode: FlashMode.none,
                ),
                builder: (cameraState, preview) {
                  final captureNotifier = ref.read(
                    petCaptureNotifierProvider.notifier,
                  );
                  captureNotifier.attachState(cameraState);

                  return Stack(
                    children: [
                      // Decorative heart icons ở dưới background
                      ..._buildDecorativeHearts(),
                      if (captureState.isPreviewMode)
                        Positioned.fill(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            opacity: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: AppColors.backgroundGradient,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!captureState.isPreviewMode) const PetPreviewMask(),
                      Column(
                        children: [
                          if (!captureState.isPreviewMode)
                            PetCaptureHeader(
                              state: captureState,
                              notifier: captureNotifier,
                              zoomLevel: _zoomLevel,
                            )
                          else
                            const SizedBox(height: 0),

                          Expanded(
                            child: _buildPreviewContainer(
                              cameraState,
                              captureState,
                              captureNotifier,
                            ),
                          ),

                          if (!captureState.isPreviewMode)
                            PetCaptureActionBar(
                              state: captureState,
                              notifier: captureNotifier,
                              onPickFromGallery: _pickFromGallery,
                              onCapture: () async {
                                _triggerFlashOverlay();
                                await captureNotifier.capturePhoto();
                              },
                            )
                          else
                            const SizedBox(height: 150),

                          if (!captureState.isPreviewMode)
                            const PetCaptureFooter(),
                        ],
                      ),

                      if (captureState.isPreviewMode)
                        PetCaptureActionBarPositioned(
                          state: captureState,
                          notifier: captureNotifier,
                          onPickFromGallery: _pickFromGallery,
                          onCapture: () async {
                            _triggerFlashOverlay();
                            await captureNotifier.capturePhoto();
                          },
                        ),

                      if (captureState.isSending)
                        const PetCaptureSendingOverlay(),
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

  Widget _buildCameraContainer(
    CameraState cameraState,
    PetCaptureState captureState,
    PetCaptureNotifier captureNotifier,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Phải khớp với tỉ lệ & kích thước trong PetPreviewMask (đã đổi về 4/3)
    final containerWidth = screenWidth * 0.92;
    final containerHeight = containerWidth * 4 / 3.5;

    // Chỉ hiển thị container khi review (lúc chụp camera tự render full màn + mask)
    if (!captureState.isPreviewMode || captureState.previewFile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: containerWidth,
      height: containerHeight,
      // Căn giữa theo chiều ngang giống PetPreviewMask
      margin: EdgeInsets.symmetric(
        horizontal: (screenWidth - containerWidth) / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44),
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(44),
            child: _buildPreview(captureState.previewFile!),
          ),
          _buildCaptionFieldOnPreview(captureState, captureNotifier),
          _buildClosePreviewButtonOnPreview(captureState, captureNotifier),
        ],
      ),
    );
  }

  Widget _buildPreviewContainer(
    CameraState cameraState,
    PetCaptureState captureState,
    PetCaptureNotifier captureNotifier,
  ) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = captureState.isPreviewMode && keyboardHeight > 0
        ? keyboardHeight * 0.8
        : 0.0;

    // Điều chỉnh padding để container review khớp với vị trí mask mớBi (đã xích lên)
    final offsetUp = 20.0;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      padding: EdgeInsets.only(top: offsetUp, bottom: 50 + bottomPadding),
      child: Center(
        child: _buildCameraContainer(
          cameraState,
          captureState,
          captureNotifier,
        ),
      ),
    );
  }

  Widget _buildPreview(File file) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Nền blur để đánh lừa cảm giác "zoom out" khi xem lại
        Image.file(file, fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.black.withOpacity(0.2)),
        ),
        // Ảnh chính hiển thị cover giống lúc preview camera
        Image.file(file, fit: BoxFit.cover),
      ],
    );
  }

  Widget _buildCaptionFieldOnPreview(
    PetCaptureState state,
    PetCaptureNotifier notifier,
  ) {
    final bottomPosition = state.isPreviewMode ? 40.0 : -120.0;
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
}
