import 'package:get/get.dart';
import 'package:pixel_love/features/auth/presentation/bindings/auth_binding.dart';
import 'package:pixel_love/features/auth/presentation/pages/auth_screen.dart';
import 'package:pixel_love/features/auth/presentation/pages/complete_profile_screen.dart';
import 'package:pixel_love/features/pet/presentation/bindings/pet_binding.dart';
import 'package:pixel_love/features/pet/presentation/pages/pet_screen.dart';
import 'package:pixel_love/features/startup/splash_screen.dart';
import 'package:pixel_love/features/startup/startup_binding.dart';
import 'package:pixel_love/features/test_map/test_map.dart';
import 'package:pixel_love/features/user/presentation/bindings/user_binding.dart';
import 'package:pixel_love/features/user/presentation/pages/user_profile_screen.dart';
import 'package:pixel_love/routes/app_routes.dart';
import 'package:pixel_love/views/home_screen.dart';

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
    GetPage(name: AppRoutes.testMap, page: () => const TestMap()),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      bindings: [UserBinding(), PetBinding()],
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
  ];
}
