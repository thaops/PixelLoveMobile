import 'package:get/get.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/auth/domain/usecases/get_me_usecase.dart';
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

      // Step 2: GET /auth/me
      final result = await _getMeUseCase.call();

      result.when(
        success: (user) {
          print('✅ User loaded: ${user.name}, mode=${user.mode}');

          // Save user to storage
          _storageService.saveUser(user);

          // Step 3: Check if need profile
          if (user.name == null || user.name!.isEmpty || user.dob == null) {
            print('→ Need profile, navigate to CompleteProfile');
            Get.offAllNamed(AppRoutes.completeProfile);
            return;
          }

          // Step 4: Navigate to home
          print('→ Navigate to Home');
          Get.offAllNamed(AppRoutes.home);
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
}

