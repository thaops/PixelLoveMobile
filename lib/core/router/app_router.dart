import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/auth/presentation/pages/auth_screen.dart';
import 'package:pixel_love/features/auth/presentation/pages/complete_profile_screen.dart';
import 'package:pixel_love/features/couple/presentation/pages/couple_connection_screen.dart';
import 'package:pixel_love/features/fridge/presentation/pages/create_note_screen.dart';
import 'package:pixel_love/features/fridge/presentation/pages/fridge_screen.dart';
import 'package:pixel_love/features/home/presentation/pages/home_screen.dart';
import 'package:pixel_love/features/pet_image/presentation/pages/pet_album_screen.dart';
import 'package:pixel_love/features/pet_image/presentation/pages/pet_album_swipe_screen.dart';
import 'package:pixel_love/features/pet_image/presentation/pages/pet_capture_screen.dart';
import 'package:pixel_love/features/pet_scene/presentation/pages/pet_scene_screen.dart';
import 'package:pixel_love/features/startup/splash_screen.dart';
import 'package:pixel_love/features/user/presentation/pages/onboard_screen.dart';
import 'package:pixel_love/features/user/presentation/pages/settings_screen.dart';
import 'package:pixel_love/features/user/presentation/pages/user_profile_screen.dart';
import 'package:pixel_love/routes/app_routes.dart';

/// App Router configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  final storageService = ref.watch(storageServiceProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final location = state.uri.path;

      // Allow splash screen always
      if (location == AppRoutes.splash) {
        return null;
      }

      // Check if user is logged in
      final token = storageService.getToken();
      print('🔑 Token: $token');
      if (token == null || token.isEmpty) {
        // Not logged in, redirect to login
        if (location != AppRoutes.login) {
          return AppRoutes.login;
        }
        return null;
      }

      // User is logged in, check user state
      final user = storageService.getUser();
      if (user == null) {
        // Token exists but no user data, go to login
        if (location != AppRoutes.login) {
          return AppRoutes.login;
        }
        return null;
      }

      // User exists, check onboarding status
      if (!user.isOnboarded) {
        if (location != AppRoutes.onboard) {
          return AppRoutes.onboard;
        }
        return null;
      }

      // User is onboarded, check mode
      if (user.mode == 'solo') {
        if (location != AppRoutes.coupleConnection) {
          return AppRoutes.coupleConnection;
        }
        return null;
      }

      if (user.mode == 'couple') {
        final hasPartner = user.partnerId != null && user.partnerId!.isNotEmpty;
        final hasCoupleRoom =
            user.coupleRoomId != null && user.coupleRoomId!.isNotEmpty;

        if (!hasCoupleRoom && !hasPartner) {
          // Not connected yet
          if (location != AppRoutes.coupleConnection) {
            return AppRoutes.coupleConnection;
          }
          return null;
        }

        // Connected, allow access to home and other routes
        return null;
      }

      // Unknown mode, default to couple-connection
      if (location != AppRoutes.coupleConnection) {
        return AppRoutes.coupleConnection;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboard,
        builder: (context, state) => const OnboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.coupleConnection,
        builder: (context, state) => const CoupleConnectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.petScene,
        builder: (context, state) => const PetSceneScreen(),
      ),
      GoRoute(
        path: AppRoutes.petAlbum,
        builder: (context, state) => const PetAlbumScreen(),
      ),
      GoRoute(
        path: AppRoutes.petAlbumSwipe,
        pageBuilder: (context, state) {
          // 🔥 Custom fade transition - ảnh review mờ dần, swipe screen hiện lên rõ dần
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const PetAlbumSwipeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // 🔥 Fade transition mượt mà - swipe screen hiện lên rõ dần
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.petCapture,
        builder: (context, state) => const PetCaptureScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.fridge,
        builder: (context, state) => const FridgeScreen(),
      ),
      GoRoute(
        path: AppRoutes.createNote,
        builder: (context, state) => const CreateNoteScreen(),
      ),
    ],
  );
});
