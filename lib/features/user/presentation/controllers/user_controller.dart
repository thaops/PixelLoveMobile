import 'package:get/get.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/user/domain/entities/user.dart';
import 'package:pixel_love/features/user/domain/usecases/complete_profile_usecase.dart';
import 'package:pixel_love/features/user/domain/usecases/update_profile_usecase.dart'
    as user_update_profile;
import 'package:pixel_love/routes/app_routes.dart';

class UserController extends GetxController {
  final CompleteProfileUseCase _completeProfileUseCase;
  final user_update_profile.UpdateProfileUseCase _updateProfileUseCase;
  final StorageService _storageService;

  UserController(
    this._completeProfileUseCase,
    this._updateProfileUseCase,
    this._storageService,
  );

  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final Rxn<User> _currentUser = Rxn<User>();

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  User? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    // Load user from storage
    final authUser = _storageService.getUser();
    if (authUser != null) {
      // Convert AuthUser to User entity
      _currentUser.value = User(
        id: authUser.id,
        name: authUser.name,
        avatar: authUser.avatar,
        email: authUser.email,
        phone: null,
        dob: authUser.dob,
        zodiac: authUser.zodiac,
        mode: authUser.mode,
        coupleCode: authUser.coupleCode,
        coupleRoomId: authUser.coupleRoomId,
        coins: authUser.coins,
        createdAt: null,
      );
    }
  }

  // For refreshing user data (called from UI)
  Future<void> fetchProfile() async {
    // Just reload from storage (startup logic already fetched from API)
    _loadUserFromStorage();
  }

  // Complete profile flow (after first login)
  Future<void> completeProfile({
    required String name,
    required String dob,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      print('📝 Completing profile: name=$name, dob=$dob');

      final result = await _completeProfileUseCase.call(name: name, dob: dob);

      result.when(
        success: (user) {
          print('✅ Profile completed: ${user.name}, zodiac=${user.zodiac}');
          _currentUser.value = user;

          // Navigate to home screen
          Get.offAllNamed(AppRoutes.home);

          Get.snackbar(
            'Success',
            'Profile completed! Welcome ${user.name}',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        error: (error) {
          _errorMessage.value = error.message;
          Get.snackbar(
            'Error',
            error.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? avatar,
    String? email,
    String? phone,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (avatar != null) data['avatar'] = avatar;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;

      final result = await _updateProfileUseCase.call(data);

      result.when(
        success: (user) {
          _currentUser.value = user;
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.back();
        },
        error: (error) {
          _errorMessage.value = error.message;
          Get.snackbar(
            'Error',
            error.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
