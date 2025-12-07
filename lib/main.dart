import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pixel_love/bindings/initial_binding.dart';
import 'package:pixel_love/core/env/env.dart';
import 'package:pixel_love/firebase_options.dart';
import 'package:pixel_love/routes/app_pages.dart';
import 'package:pixel_love/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GetStorage.init();

  await Env.load();

  runApp(const PixelLoveApp());
}

class PixelLoveApp extends StatelessWidget {
  const PixelLoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pixel Love',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialBinding: InitialBinding(),
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
    );
  }

  String _getInitialRoute() {
    // Always start with splash screen
    // Startup logic will handle navigation based on auth state
    return AppRoutes.splash;
  }
}
