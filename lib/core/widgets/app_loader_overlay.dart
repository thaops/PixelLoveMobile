import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/custom_loading_widget.dart';

/// Custom loading overlay widget for app-wide use
/// Wrap your app with this widget to enable loading overlay throughout the app
class AppLoaderOverlay extends StatelessWidget {
  final Widget child;

  const AppLoaderOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      overlayWidgetBuilder: (_) => const _AppLoadingOverlay(),
      child: child,
    );
  }
}

/// Custom loading overlay UI
/// This widget defines the visual appearance of the loading overlay
class _AppLoadingOverlay extends StatelessWidget {
  const _AppLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const CustomLoadingWidget(size: 120)],
        ),
      ),
    );
  }
}

/// Extension methods for easier access to loader overlay
extension AppLoaderOverlayExtension on BuildContext {
  /// Show loading overlay
  void showAppLoader() {
    loaderOverlay.show();
  }

  /// Hide loading overlay
  void hideAppLoader() {
    loaderOverlay.hide();
  }

  /// Check if loader is visible
  bool get isAppLoaderVisible => loaderOverlay.visible;
}
