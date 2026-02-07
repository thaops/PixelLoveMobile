import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/home/data/models/home_dto.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';
import 'package:pixel_love/features/startup/notifiers/startup_notifier.dart';
import 'package:pixel_love/routes/app_routes.dart';

class SplashController {
  final WidgetRef ref;
  final BuildContext context;
  final VoidCallback onStateChanged;

  bool hasNavigated = false;

  SplashController({
    required this.ref,
    required this.context,
    required this.onStateChanged,
  });

  Future<bool> waitForImageToRender(
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

  Future<void> preloadHomeBackground() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final cachedData = storageService.getHomeData();

      String? imageUrl;

      if (cachedData != null) {
        try {
          final homeDto = HomeDto.fromJson(cachedData);
          imageUrl = homeDto.background.imageUrl;
        } catch (_) {}
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        final getHomeDataUseCase = ref.read(getHomeDataUseCaseProvider);
        final result = await getHomeDataUseCase.call();

        result.when(
          success: (home) {
            imageUrl = home.background.imageUrl;
          },
          error: (error) {
            return;
          },
        );
      }

      if (imageUrl != null && imageUrl!.isNotEmpty && context.mounted) {
        final imageProvider = NetworkImage(imageUrl!);
        await precacheImage(imageProvider, context);
        await waitForImageToRender(imageProvider, context);
      }
    } catch (_) {}
  }

  Future<void> navigateBasedOnState() async {
    if (!context.mounted) return;

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
        await preloadHomeBackground();
        if (context.mounted) {
          context.go(AppRoutes.home);
        }
      } else {
        context.go(AppRoutes.coupleConnection);
      }
    } else {
      context.go(AppRoutes.coupleConnection);
    }
  }

  void handleStateChange(AsyncValue<StartupState> state) {
    if (hasNavigated) return;

    state.when(
      data: (data) {
        if (!data.isLoading && context.mounted) {
          hasNavigated = true;
          navigateBasedOnState();
        }
      },
      loading: () {},
      error: (error, stack) {
        if (context.mounted && !hasNavigated) {
          hasNavigated = true;
          context.go(AppRoutes.login);
        }
      },
    );
  }
}
