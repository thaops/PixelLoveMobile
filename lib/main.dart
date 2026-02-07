import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixel_love/core/env/env.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/core/router/app_router.dart';
import 'package:pixel_love/core/utils/image_cache_helper.dart';
import 'package:pixel_love/core/widgets/app_loader_overlay.dart';
import 'package:pixel_love/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Env.load();

  MobileAds.instance.initialize();

  ImageCacheHelper.initialize();

  // Initialize SharedPreferences before ProviderScope
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const PixelLoveApp(),
    ),
  );
}

class PixelLoveApp extends ConsumerWidget {
  const PixelLoveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return AppLoaderOverlay(
      child: MaterialApp.router(
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
        routerConfig: router,
      ),
    );
  }
}
