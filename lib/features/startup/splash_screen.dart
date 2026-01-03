import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/custom_loading_widget.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/startup/providers/startup_providers.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';
import 'package:pixel_love/features/home/data/models/home_dto.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _waitForImageToRender(
    ImageProvider imageProvider,
    BuildContext context, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<bool>();

    late ImageStreamListener listener;
    final imageStream = imageProvider.resolve(
      createLocalImageConfiguration(context),
    );

    Timer? timer;

    listener = ImageStreamListener(
      (ImageInfo image, bool synchronousCall) async {
        if (completer.isCompleted) return;

        timer?.cancel();

        // ⏱️ ĐỢI FRAME ĐẦU TIÊN ĐƯỢC VẼ
        await WidgetsBinding.instance.endOfFrame;

        completer.complete(true);
        imageStream.removeListener(listener);
      },
      onError: (error, stackTrace) {
        if (completer.isCompleted) return;

        timer?.cancel();
        completer.complete(false);
        imageStream.removeListener(listener);
      },
    );

    imageStream.addListener(listener);

    timer = Timer(timeout, () {
      if (completer.isCompleted) return;

      completer.complete(false);
      imageStream.removeListener(listener);
    });

    return completer.future;
  }

  Future<void> _preloadAndWaitForHomeBackground() async {
    try {
      // Lấy home data từ cache trước (nhanh)
      final storageService = ref.read(storageServiceProvider);
      final cachedData = storageService.getHomeData();

      String? imageUrl;

      if (cachedData != null) {
        try {
          final homeDto = HomeDto.fromJson(cachedData);
          imageUrl = homeDto.background.imageUrl;
        } catch (e) {
          print('⚠️ Cache parse error: $e');
        }
      }

      // Nếu không có cache, gọi API để lấy URL
      if (imageUrl == null || imageUrl.isEmpty) {
        final getHomeDataUseCase = ref.read(getHomeDataUseCaseProvider);
        final result = await getHomeDataUseCase.call();

        result.when(
          success: (home) {
            imageUrl = home.background.imageUrl;
          },
          error: (error) {
            print('⚠️ Failed to get home data: ${error.message}');
            return; // Không preload được, nhưng vẫn navigate
          },
        );
      }

      // Đợi ảnh được render nếu có URL (dùng NetworkImage để cache vào ImageCache của Flutter)
      if (imageUrl != null && imageUrl!.isNotEmpty && mounted) {
        // Precache vào ImageCache của Flutter (Image.network sẽ dùng cache này)
        final imageProvider = NetworkImage(imageUrl!);
        await precacheImage(imageProvider, context);

        // Đợi render xong để đảm bảo ảnh đã sẵn sàng
        final rendered = await _waitForImageToRender(imageProvider, context);
        if (rendered) {
          print('✅ Home background image cached and rendered successfully');
        } else {
          print('⚠️ Timeout or error rendering image, proceeding anyway');
        }
      }
    } catch (e) {
      print('⚠️ Preload error: $e');
      // Vẫn tiếp tục navigate dù preload lỗi
    }
  }

  Future<void> _navigateBasedOnState() async {
    if (!mounted) {
      return;
    }

    final storageService = ref.read(storageServiceProvider);
    final token = storageService.getToken();

    if (token == null || token.isEmpty) {
      context.go(AppRoutes.login);
      return;
    }

    final user = storageService.getUser();
    if (user == null) {
      context.go(AppRoutes.login);
      return;
    }

    if (!user.isOnboarded) {
      context.go(AppRoutes.onboard);
    } else if (user.mode == 'solo') {
      context.go(AppRoutes.coupleConnection);
    } else if (user.mode == 'couple') {
      final hasPartner = user.partnerId != null && user.partnerId!.isNotEmpty;
      final hasCoupleRoom =
          user.coupleRoomId != null && user.coupleRoomId!.isNotEmpty;

      if (hasCoupleRoom || hasPartner) {
        await _preloadAndWaitForHomeBackground();
        if (mounted) {
          context.go(AppRoutes.home);
        }
      } else {
        context.go(AppRoutes.coupleConnection);
      }
    } else {
      context.go(AppRoutes.coupleConnection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startupState = ref.watch(startupNotifierProvider);

    ref.listen(startupNotifierProvider, (previous, next) {
      if (_hasNavigated) return;

      next.when(
        data: (state) {
          if (!state.isLoading && mounted) {
            _hasNavigated = true;
            _navigateBasedOnState();
          }
        },
        loading: () {},
        error: (error, stack) {
          if (mounted && !_hasNavigated) {
            _hasNavigated = true;
            context.go(AppRoutes.login);
          }
        },
      );
    });

    // Also check current state immediately on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasNavigated && mounted) {
        startupState.when(
          data: (state) {
            if (!state.isLoading) {
              _hasNavigated = true;
              _navigateBasedOnState();
            }
          },
          loading: () {
            // Will be handled by listener
          },
          error: (error, stack) {
            if (!_hasNavigated) {
              _hasNavigated = true;
              context.go(AppRoutes.login);
            }
          },
        );
      }
    });

    return Scaffold(
      body: LoveBackground(
        showDecorativeIcons: false,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Opacity(
                opacity: 1,
                child: Image.asset(
                  'assets/images/backgroud-splash.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  startupState.when(
                    data: (state) {
                      if (state.isLoading) {
                        return CustomLoadingWidget(size: 120);
                      } else if (state.errorMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(color: AppColors.errorText),
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    loading: () => const CustomLoadingWidget(),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        error.toString(),
                        style: TextStyle(color: AppColors.errorText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
