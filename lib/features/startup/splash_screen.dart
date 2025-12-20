import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/custom_loading_widget.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/startup/providers/startup_providers.dart';

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
    print('🚀 [SplashScreen] Initializing...');
  }

  Future<void> _navigateBasedOnState() async {
    if (!mounted) {
      print('⚠️ [SplashScreen] Widget not mounted, skipping navigation');
      return;
    }

    print('🧭 [SplashScreen] Determining navigation...');

    final storageService = ref.read(storageServiceProvider);
    final token = storageService.getToken();

    if (token == null || token.isEmpty) {
      print('➡️ [SplashScreen] No token, navigating to login');
      context.go(AppRoutes.login);
      return;
    }

    final user = storageService.getUser();
    if (user == null) {
      print('➡️ [SplashScreen] No user data, navigating to login');
      context.go(AppRoutes.login);
      return;
    }

    print(
      '👤 [SplashScreen] User found: mode=${user.mode}, isOnboarded=${user.isOnboarded}',
    );

    // Navigate based on user state
    if (!user.isOnboarded) {
      print('➡️ [SplashScreen] User not onboarded, navigating to onboard');
      context.go(AppRoutes.onboard);
    } else if (user.mode == 'solo') {
      print('➡️ [SplashScreen] Solo mode, navigating to couple-connection');
      context.go(AppRoutes.coupleConnection);
    } else if (user.mode == 'couple') {
      final hasPartner = user.partnerId != null && user.partnerId!.isNotEmpty;
      final hasCoupleRoom =
          user.coupleRoomId != null && user.coupleRoomId!.isNotEmpty;

      if (hasCoupleRoom || hasPartner) {
        print('➡️ [SplashScreen] Couple connected, navigating to home');
        context.go(AppRoutes.home);
      } else {
        print(
          '➡️ [SplashScreen] Couple not connected, navigating to couple-connection',
        );
        context.go(AppRoutes.coupleConnection);
      }
    } else {
      print('➡️ [SplashScreen] Unknown mode, navigating to couple-connection');
      context.go(AppRoutes.coupleConnection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startupState = ref.watch(startupNotifierProvider);

    // Listen to state changes and navigate when ready
    ref.listen(startupNotifierProvider, (previous, next) {
      if (_hasNavigated) return;

      next.when(
        data: (state) {
          print(
            '📊 [SplashScreen] Startup state updated: isLoading=${state.isLoading}',
          );
          if (!state.isLoading && mounted) {
            _hasNavigated = true;
            _navigateBasedOnState();
          }
        },
        loading: () {
          print('⏳ [SplashScreen] Startup still loading...');
        },
        error: (error, stack) {
          print('❌ [SplashScreen] Startup error: $error');
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
                        return const CustomLoadingWidget(showBackdrop: false);
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
                    loading: () =>
                        const CustomLoadingWidget(showBackdrop: false),
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
