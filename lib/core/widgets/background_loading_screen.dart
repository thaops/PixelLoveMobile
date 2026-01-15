import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/utils/image_loader_utils.dart';
import 'package:pixel_love/core/widgets/love_background.dart';

/// Widget loading screen dùng chung cho các màn hình có background image
/// Hiển thị progress bar theo style của app
class BackgroundLoadingScreen extends ConsumerStatefulWidget {
  final String backgroundImageUrl;
  final String? title;
  final String? subtitle;
  final VoidCallback? onLoadComplete;
  final VoidCallback? onLoadError;

  const BackgroundLoadingScreen({
    super.key,
    required this.backgroundImageUrl,
    this.title,
    this.subtitle,
    this.onLoadComplete,
    this.onLoadError,
  });

  @override
  ConsumerState<BackgroundLoadingScreen> createState() =>
      _BackgroundLoadingScreenState();
}

class _BackgroundLoadingScreenState
    extends ConsumerState<BackgroundLoadingScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  Completer<bool>? _loadCompleter;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCacheAndLoad();
    });
  }

  /// Kiểm tra cache trước, nếu đã cache thì skip loading screen
  Future<void> _checkCacheAndLoad() async {
    if (!mounted) return;

    try {
      // Kiểm tra xem ảnh đã được cache chưa bằng cách resolve image
      final imageProvider = CachedNetworkImageProvider(
        widget.backgroundImageUrl,
      );
      final imageStream = imageProvider.resolve(
        createLocalImageConfiguration(context),
      );

      // Tạo completer để đợi kết quả
      final cacheCompleter = Completer<bool>();
      late ImageStreamListener listener;
      Timer? cacheTimer;

      listener = ImageStreamListener(
        (ImageInfo imageInfo, bool synchronousCall) {
          // Nếu synchronousCall = true → ảnh đã cache và load ngay (không cần download)
          if (!cacheCompleter.isCompleted) {
            cacheTimer?.cancel();
            imageStream.removeListener(listener);
            // Nếu synchronousCall = true → đã cache, ngược lại → đang download
            cacheCompleter.complete(synchronousCall);
          }
        },
        onError: (error, stackTrace) {
          // Lỗi → chưa cache hoặc lỗi
          if (!cacheCompleter.isCompleted) {
            cacheTimer?.cancel();
            imageStream.removeListener(listener);
            cacheCompleter.complete(false);
          }
        },
      );

      imageStream.addListener(listener);

      // Timeout sau 50ms để check cache (nếu cache sẽ trả về ngay)
      cacheTimer = Timer(const Duration(milliseconds: 50), () {
        if (!cacheCompleter.isCompleted) {
          imageStream.removeListener(listener);
          // Timeout → có thể đang download hoặc chưa cache
          cacheCompleter.complete(false);
        }
      });

      final isCached = await cacheCompleter.future;

      if (isCached && mounted) {
        // Ảnh đã cache → skip loading screen, gọi onLoadComplete ngay
        print('✅ Image already cached, skipping loading screen');
        widget.onLoadComplete?.call();
        return;
      }

      // Ảnh chưa cache → hiển thị loading screen
      _loadBackground();
    } catch (e) {
      print('⚠️ Error checking cache: $e');
      // Nếu lỗi check cache, vẫn hiển thị loading screen
      _loadBackground();
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBackground() async {
    if (!mounted) return;

    try {
      // Reset progress
      ref.read(backgroundLoadingProgressProvider.notifier).reset();
      _loadCompleter = Completer<bool>();

      // Timeout sau 10 giây
      _timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (!_loadCompleter!.isCompleted && mounted) {
          _loadCompleter!.complete(false);
        }
      });

      // Trigger load bằng cách rebuild với CachedNetworkImage
      setState(() {});
    } catch (e) {
      print('⚠️ Error loading background: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        widget.onLoadError?.call();
      }
    }
  }

  /// Đợi ảnh render xong và update progress lên 100%
  Future<void> _waitForRender(ImageProvider imageProvider) async {
    try {
      // Đợi render
      final rendered = await ImageLoaderUtils.waitForImageToRender(
        imageProvider,
        context,
      );

      if (rendered && mounted) {
        // Render xong → 100%
        ref.read(backgroundLoadingProgressProvider.notifier).update(100.0);

        // Đợi thêm một chút để progress bar hiển thị 100%
        await Future.delayed(const Duration(milliseconds: 200));

        if (mounted && _loadCompleter != null && !_loadCompleter!.isCompleted) {
          _loadCompleter!.complete(true);
          setState(() {
            _isLoading = false;
          });
          widget.onLoadComplete?.call();
        }
      } else {
        if (mounted && _loadCompleter != null && !_loadCompleter!.isCompleted) {
          _loadCompleter!.complete(false);
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
          widget.onLoadError?.call();
        }
      }
    } catch (e) {
      print('⚠️ Error waiting for render: $e');
      if (mounted && _loadCompleter != null && !_loadCompleter!.isCompleted) {
        _loadCompleter!.complete(false);
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        widget.onLoadError?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(backgroundLoadingProgressProvider);

    return Scaffold(
      body: LoveBackground(
        showDecorativeIcons: true,
        child: Stack(
          children: [
            // Offscreen widget để trigger download và track progress
            Positioned(
              left: -1000,
              top: -1000,
              child: SizedBox(
                width: 1,
                height: 1,
                child: CachedNetworkImage(
                  imageUrl: widget.backgroundImageUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) {
                    if (downloadProgress.progress != null) {
                      // Download progress: 0-90%
                      final downloadPercent = downloadProgress.progress! * 90;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ref
                              .read(backgroundLoadingProgressProvider.notifier)
                              .update(downloadPercent);
                        }
                      });
                    } else {
                      // Cache hit → 90%
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ref
                              .read(backgroundLoadingProgressProvider.notifier)
                              .update(90.0);
                        }
                      });
                    }
                    return const SizedBox.shrink();
                  },
                  errorWidget: (context, url, error) {
                    if (mounted && _isLoading) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _hasError = true;
                            _isLoading = false;
                          });
                          if (_loadCompleter != null &&
                              !_loadCompleter!.isCompleted) {
                            _loadCompleter!.complete(false);
                          }
                          widget.onLoadError?.call();
                        }
                      });
                    }
                    return const SizedBox.shrink();
                  },
                  imageBuilder: (context, imageProvider) {
                    // Ảnh đã load xong, đợi render
                    if (_isLoading && mounted && _loadCompleter != null) {
                      _waitForRender(imageProvider);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),

            // UI Loading
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lotties/pet-doggie-loading.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),

                  if (widget.title != null) ...[
                    Text(
                      widget.title!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // // Subtitle
                  // if (widget.subtitle != null) ...[
                  //   Text(
                  //     widget.subtitle!,
                  //     style: const TextStyle(
                  //       color: AppColors.textSecondary,
                  //       fontSize: 16,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  //   const SizedBox(height: 32),
                  // ],

                  // Progress Bar
                  Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Progress text
                        Text(
                          '${progress.toInt()}%',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // // Error message
                  // if (_hasError) ...[
                  //   const SizedBox(height: 24),
                  //   Text(
                  //     'Không thể tải ảnh nền',
                  //     style: TextStyle(
                  //       color: AppColors.errorText,
                  //       fontSize: 14,
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
