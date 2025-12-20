import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/core/services/image_preload_service.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';
import 'package:pixel_love/features/auth/providers/auth_providers.dart';
import 'package:pixel_love/features/home/data/models/home_dto.dart';
import 'package:pixel_love/core/network/api_result.dart';

/// Startup State
class StartupState {
  final bool isLoading;
  final String? errorMessage;
  final AuthUser? user;

  const StartupState({
    this.isLoading = true,
    this.errorMessage,
    this.user,
  });

  StartupState copyWith({
    bool? isLoading,
    String? errorMessage,
    AuthUser? user,
  }) {
    return StartupState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

/// Startup Notifier - Handles app initialization and routing logic
class StartupNotifier extends AsyncNotifier<StartupState> {
  @override
  Future<StartupState> build() async {
    // Initial state
    state = const AsyncValue.data(StartupState(isLoading: true));
    
    // Start initialization
    await _initializeApp();
    
    // Return final state
    return state.value ?? const StartupState(isLoading: false);
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // Splash delay

      final storageService = ref.read(storageServiceProvider);
      
      // Step 1: Check if user has token
      final token = storageService.getToken();

      if (token == null || token.isEmpty) {
        print('❌ No token found, navigate to login');
        state = AsyncValue.data(
          const StartupState(isLoading: false, errorMessage: null),
        );
        return;
      }

      print('✅ Token found, checking user status...');

      // 🚀 PARALLEL: API call + Preload assets
      final dioApi = ref.read(dioApiProvider);
      final getMeUseCase = ref.read(getMeUseCaseProvider);
      
      // Start both tasks simultaneously
      final results = await Future.wait([
        // Task 1: Get user info
        getMeUseCase.call(),
        // Task 2: Preload home data + images (if going to home)
        _preloadHomeAssets(dioApi, storageService),
      ], eagerError: false);

      final userResult = results[0] as ApiResult<AuthUser>;

      userResult.when(
        success: (user) {
          print('✅ User loaded: name=${user.name}, mode=${user.mode}, isOnboarded=${user.isOnboarded}');

          // Save user to storage
          storageService.saveUser(user);

          state = AsyncValue.data(
            StartupState(isLoading: false, user: user),
          );
        },
        error: (error) {
          print('❌ Get me error: ${error.message}');

          // If 401, clear storage
          if (error.message.contains('401') ||
              error.message.toLowerCase().contains('unauthorized')) {
            storageService.clearAll();
          }

          state = AsyncValue.data(
            StartupState(
              isLoading: false,
              errorMessage: error.message,
            ),
          );
        },
      );
    } catch (e) {
      print('❌ Startup error: $e');
      state = AsyncValue.data(
        StartupState(
          isLoading: false,
          errorMessage: 'Unexpected error: $e',
        ),
      );
    }
  }

  Future<void> _preloadHomeAssets(
    DioApi dioApi,
    StorageService storageService,
  ) async {
    try {
      // Fetch home data
      final homeResult = await dioApi.get(
        '/home',
        fromJson: (json) => HomeDto.fromJson(json),
      );

      homeResult.when(
        success: (homeDto) {
          // Save to cache
          storageService.saveHomeData(homeDto.toJson());
          
          // Collect all image URLs
          final imageUrls = <String>[];
          
          // Background image
          if (homeDto.background.imageUrl.isNotEmpty) {
            imageUrls.add(homeDto.background.imageUrl);
          }
          
          // Object images
          for (final obj in homeDto.objects) {
            if (obj.imageUrl.isNotEmpty) {
              imageUrls.add(obj.imageUrl);
            }
          }
          
          // Preload all images in parallel (non-blocking)
          if (imageUrls.isNotEmpty) {
            ImagePreloadService.preloadImages(imageUrls);
            print('✅ Home assets preloaded: ${imageUrls.length} images');
          }
        },
        error: (error) {
          print('⚠️ Preload home failed (non-critical): ${error.message}');
          // Don't block navigation if preload fails
        },
      );
    } catch (e) {
      print('⚠️ Preload exception (non-critical): $e');
      // Don't block navigation if preload fails
    }
  }
}

