import 'package:get/get.dart';
import 'package:pixel_love/features/auth/presentation/bindings/auth_binding.dart';
import 'package:pixel_love/features/auth/presentation/pages/auth_screen.dart';
import 'package:pixel_love/features/auth/presentation/pages/complete_profile_screen.dart';
import 'package:pixel_love/features/couple/presentation/bindings/couple_binding.dart';
import 'package:pixel_love/features/couple/presentation/pages/couple_connection_screen.dart';
import 'package:pixel_love/features/pet/presentation/bindings/pet_binding.dart';
import 'package:pixel_love/features/pet/presentation/pages/pet_screen.dart';
import 'package:pixel_love/features/startup/splash_screen.dart';
import 'package:pixel_love/features/startup/startup_binding.dart';
import 'package:pixel_love/features/home/presentation/bindings/home_binding.dart';
import 'package:pixel_love/features/home/presentation/pages/home_screen.dart';
import 'package:pixel_love/features/user/presentation/bindings/user_binding.dart';
import 'package:pixel_love/features/user/presentation/pages/onboard_screen.dart';
import 'package:pixel_love/features/user/presentation/pages/settings_screen.dart';
import 'package:pixel_love/features/user/presentation/pages/user_profile_screen.dart';
import 'package:pixel_love/features/pet_scene/presentation/bindings/pet_scene_binding.dart';
import 'package:pixel_love/features/pet_scene/presentation/pages/pet_scene_screen.dart';
import 'package:pixel_love/routes/app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: StartupBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.completeProfile,
      page: () => const CompleteProfileScreen(),
      bindings: [UserBinding()],
    ),
    GetPage(
      name: AppRoutes.onboard,
      page: () => const OnboardScreen(),
      bindings: [UserBinding()],
    ),
    GetPage(
      name: AppRoutes.coupleConnection,
      page: () => const CoupleConnectionScreen(),
      binding: CoupleBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      bindings: [HomeBinding(), UserBinding()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const UserProfileScreen(),
      bindings: [UserBinding(), AuthBinding()],
    ),
    GetPage(
      name: AppRoutes.pet,
      page: () => const PetScreen(),
      binding: PetBinding(),
    ),
    GetPage(
      name: AppRoutes.petScene,
      page: () => const PetSceneScreen(),
      binding: PetSceneBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      bindings: [UserBinding()],
    ),
  ];
}
