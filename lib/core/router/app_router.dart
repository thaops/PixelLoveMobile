import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/auth/presentation/pages/auth_screen.dart';
import 'package:pixel_love/features/auth/presentation/pages/complete_profile_screen.dart';
import 'package:pixel_love/features/couple/presentation/pages/couple_connection_screen.dart';
import 'package:pixel_love/features/home/presentation/pages/home_screen.dart';
import 'package:pixel_love/features/pet_image/presentation/pages/pet_album_screen.dart';
import 'package:pixel_love/features/pet_image/presentation/pages/pet_capture_screen.dart';
import 'package:pixel_love/features/pet_scene/presentation/pages/pet_scene_screen.dart';
import 'package:pixel_love/features/startup/splash_screen.dart';
import 'package:pixel_love/features/user/presentation/pages/onboard_screen.dart';
import 'package:pixel_love/features/user/presentation/pages/settings_screen.dart';
import 'package:pixel_love/features/user/presentation/pages/user_profile_screen.dart';

/// App Router configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.uri.path;
      
      // Allow splash screen always
      if (location == '/splash') {
        return null;
      }
      
      // Check if user is logged in
      final token = storageService.getToken();
      if (token == null || token.isEmpty) {
        // Not logged in, redirect to login
        if (location != '/login') {
          return '/login';
        }
        return null;
      }
      
      // User is logged in, check user state
      final user = storageService.getUser();
      if (user == null) {
        // Token exists but no user data, go to login
        if (location != '/login') {
          return '/login';
        }
        return null;
      }
      
      // User exists, check onboarding status
      if (!user.isOnboarded) {
        if (location != '/onboard') {
          return '/onboard';
        }
        return null;
      }
      
      // User is onboarded, check mode
      if (user.mode == 'solo') {
        if (location != '/couple-connection') {
          return '/couple-connection';
        }
        return null;
      }
      
      if (user.mode == 'couple') {
        final hasPartner = user.partnerId != null && user.partnerId!.isNotEmpty;
        final hasCoupleRoom = user.coupleRoomId != null && user.coupleRoomId!.isNotEmpty;
        
        if (!hasCoupleRoom && !hasPartner) {
          // Not connected yet
          if (location != '/couple-connection') {
            return '/couple-connection';
          }
          return null;
        }
        
        // Connected, allow access to home and other routes
        return null;
      }
      
      // Unknown mode, default to couple-connection
      if (location != '/couple-connection') {
        return '/couple-connection';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/onboard',
        builder: (context, state) => const OnboardScreen(),
      ),
      GoRoute(
        path: '/couple-connection',
        builder: (context, state) => const CoupleConnectionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/pet-scene',
        builder: (context, state) => const PetSceneScreen(),
      ),
      GoRoute(
        path: '/pet-album',
        builder: (context, state) => const PetAlbumScreen(),
      ),
      GoRoute(
        path: '/pet-capture',
        builder: (context, state) => const PetCaptureScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

