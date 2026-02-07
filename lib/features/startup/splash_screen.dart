import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/startup/controllers/splash_controller.dart';
import 'package:pixel_love/features/startup/providers/startup_providers.dart';
import 'package:pixel_love/features/startup/widgets/splash_background_image.dart';
import 'package:pixel_love/features/startup/widgets/splash_content.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashController(
      ref: ref,
      context: context,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final startupState = ref.watch(startupNotifierProvider);

    ref.listen(startupNotifierProvider, (previous, next) {
      _controller.handleStateChange(next);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasNavigated && mounted) {
        _controller.handleStateChange(startupState);
      }
    });

    return Scaffold(
      body: LoveBackground(
        showDecorativeIcons: false,
        child: Stack(
          children: [
            const SplashBackgroundImage(),
            SplashContent(startupState: startupState),
          ],
        ),
      ),
    );
  }
}
