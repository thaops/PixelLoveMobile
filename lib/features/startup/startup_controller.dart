import 'package:get/get.dart';
import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/core/services/image_preload_service.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';
import 'package:pixel_love/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:pixel_love/features/home/data/models/home_dto.dart';
import 'package:pixel_love/routes/app_routes.dart';

class StartupController extends GetxController {
  final StorageService _storageService;
  final GetMeUseCase _getMeUseCase;

  StartupController(this._storageService, this._getMeUseCase);

  final _isLoading = true.obs;
  final _errorMessage = ''.obs;

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // Splash delay

      // Step 1: Check if user has token
      final token = _storageService.getToken();

      if (token == null || token.isEmpty) {
        print('❌ No token found, navigate to login');
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      print('✅ Token found, checking user status...');

      // 🚀 PARALLEL: API call + Preload assets
      final dioApi = Get.find<DioApi>();
      
      // Start both tasks simultaneously
      final results = await Future.wait([
        // Task 1: Get user info
        _getMeUseCase.call(),
        // Task 2: Preload home data + images (if going to home)
        _preloadHomeAssets(dioApi),
      ], eagerError: false);

      final userResult = results[0] as ApiResult<AuthUser>;

      userResult.when(
        success: (user) {
          print('✅ User loaded: name=${user.name}, mode=${user.mode}, isOnboarded=${user.isOnboarded}');

          // Save user to storage
          _storageService.saveUser(user);

          // ✅ LOGIC ROUTING CHUẨN
          // CASE A: Chưa onboard
          if (!user.isOnboarded) {
            print('→ isOnboarded=false, navigate to /onboard');
            Get.offAllNamed(AppRoutes.onboard);
            return;
          }

          // CASE B: Đã onboard
          // CASE B1: mode = solo → /couple-connection
          if (user.mode == 'solo') {
            print('→ mode=solo, navigate to /couple-connection');
            Get.offAllNamed(AppRoutes.coupleConnection);
            return;
          }

          // CASE B2: mode = couple
          if (user.mode == 'couple') {
            // ✅ Dùng biến hasPartner cho rõ ràng
            final hasPartner = user.partnerId != null && user.partnerId!.isNotEmpty;
            
            if (!hasPartner) {
              print('→ mode=couple nhưng chưa có partner, navigate to /couple-connection');
              Get.offAllNamed(AppRoutes.coupleConnection);
              return;
            }

            // Đã có partner → /home (cache already preloaded)
            print('→ mode=couple + có partner, navigate to /home');
            Get.offAllNamed(AppRoutes.home);
            return;
          }

          // ✅ Default: unknown mode → /couple-connection (không vào home)
          print('→ Unknown mode, default to /couple-connection');
          Get.offAllNamed(AppRoutes.coupleConnection);
        },
        error: (error) {
          print('❌ Get me error: ${error.message}');
          _errorMessage.value = error.message;

          // If 401, clear storage and go to login
          if (error.message.contains('401') ||
              error.message.toLowerCase().contains('unauthorized')) {
            _storageService.clearAll();
            Get.offAllNamed(AppRoutes.login);
          } else {
            // Other errors, show error screen
            Get.snackbar(
              'Error',
              error.message,
              snackPosition: SnackPosition.BOTTOM,
            );
            Get.offAllNamed(AppRoutes.login);
          }
        },
      );
    } catch (e) {
      print('❌ Startup error: $e');
      _errorMessage.value = 'Unexpected error: $e';
      Get.offAllNamed(AppRoutes.login);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _preloadHomeAssets(DioApi dioApi) async {
    try {
      // Fetch home data
      final homeResult = await dioApi.get(
        '/home',
        fromJson: (json) => HomeDto.fromJson(json),
      );

      homeResult.when(
        success: (homeDto) {
          // Save to cache
          _storageService.saveHomeData(homeDto.toJson());
          
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

