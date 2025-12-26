import 'dart:io';

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
import 'package:pixel_love/features/pet_image/presentation/widgets/decorative_hearts.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_preview_image.dart';

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
                previewFit: CameraPreviewFit.contain,
                previewAlignment: const Alignment(0, -0.37),
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

                  return Stack(
                    children: [
                      const DecorativeHearts(),
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

                      if (_flashOverlay)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white,
                            child: const SizedBox.shrink(),
                          ),
                        ),
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

  Widget _buildPreviewContainer(
    CameraState cameraState,
    PetCaptureState captureState,
    PetCaptureNotifier captureNotifier,
  ) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = captureState.isPreviewMode && keyboardHeight > 0
        ? keyboardHeight * 0.8
        : 0.0;

    final offsetUp = 55.0;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      padding: EdgeInsets.only(top: offsetUp, bottom: bottomPadding),
      child: Center(
        child: PetPreviewImage(state: captureState, notifier: captureNotifier),
      ),
    );
  }
}
