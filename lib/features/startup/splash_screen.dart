import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/core/router/app_router.dart';
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
  @override
  void initState() {
    super.initState();
    // Trigger initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final startupState = ref.read(startupNotifierProvider);
    
    // Wait for initialization to complete
    await startupState.when(
      data: (state) async {
        if (!state.isLoading) {
          await _navigateBasedOnState();
        }
      },
      loading: () async {
        // Still loading, wait a bit more
        await Future.delayed(const Duration(milliseconds: 500));
        await _navigateBasedOnState();
      },
      error: (error, stack) async {
        // Error occurred, navigate to login
        if (mounted) {
          context.go('/login');
        }
      },
    );
  }

  Future<void> _navigateBasedOnState() async {
    if (!mounted) return;
    
    final storageService = ref.read(storageServiceProvider);
    final token = storageService.getToken();
    
    if (token == null || token.isEmpty) {
      context.go('/login');
      return;
    }
    
    final user = storageService.getUser();
    if (user == null) {
      context.go('/login');
      return;
    }
    
    // Navigate based on user state
    if (!user.isOnboarded) {
      context.go('/onboard');
    } else if (user.mode == 'solo') {
      context.go('/couple-connection');
    } else if (user.mode == 'couple') {
      final hasPartner = user.partnerId != null && user.partnerId!.isNotEmpty;
      final hasCoupleRoom = user.coupleRoomId != null && user.coupleRoomId!.isNotEmpty;
      
      if (hasCoupleRoom || hasPartner) {
        context.go('/home');
      } else {
        context.go('/couple-connection');
      }
    } else {
      context.go('/couple-connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final startupState = ref.watch(startupNotifierProvider);

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
                    loading: () => const CustomLoadingWidget(showBackdrop: false),
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
