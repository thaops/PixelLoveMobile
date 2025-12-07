import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';
import 'package:pixel_love/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:pixel_love/features/auth/domain/usecases/login_google_usecase.dart';
import 'package:pixel_love/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pixel_love/routes/app_routes.dart';

class AuthController extends GetxController {
  final LoginGoogleUseCase _loginGoogleUseCase;
  final GetMeUseCase _getMeUseCase;
  final LogoutUseCase _logoutUseCase;
  final StorageService _storageService;

  AuthController(
    this._loginGoogleUseCase,
    this._getMeUseCase,
    this._logoutUseCase,
    this._storageService,
  );

  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final Rxn<AuthUser> _currentUser = Rxn<AuthUser>();
  final _needProfile = false.obs;

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  AuthUser? get currentUser => _currentUser.value;
  bool get needProfile => _needProfile.value;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    final user = _storageService.getUser();
    if (user != null) {
      _currentUser.value = user;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // 1. Get Google user
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _errorMessage.value = 'Google sign in cancelled';
        return;
      }

      // 2. Get accessToken (backend requires accessToken!)
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      print('idToken: $idToken');

      if (idToken == null) {
        _errorMessage.value = 'Failed to get Google access token';
        return;
      }

      // 3. Send accessToken to backend
      final result = await _loginGoogleUseCase.call(idToken);

      result.when(
        success: (response) {
          print('✅ Login success');

          // 4. Save token
          _storageService.saveToken(response.token);

          // 5. Save user
          _currentUser.value = response.user;
          _storageService.saveUser(response.user);
          _needProfile.value = response.needProfile;

          // 6. Navigate based on needProfile
          if (response.needProfile) {
            print('→ Navigate to CompleteProfile');
            Get.offAllNamed(AppRoutes.completeProfile);
          } else {
            print('→ Navigate to Home');
            Get.offAllNamed(AppRoutes.home);
          }
        },
        error: (error) {
          _errorMessage.value = error.message;
          Get.snackbar(
            'Login Failed',
            error.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      _errorMessage.value = 'Google login error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Get current user from backend
  Future<void> getMe() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _getMeUseCase.call();

      result.when(
        success: (user) {
          _currentUser.value = user;
          _storageService.saveUser(user);
          print('✅ User loaded: ${user.name}');
        },
        error: (error) {
          _errorMessage.value = error.message;
          print('❌ Get me error: ${error.message}');
        },
      );
    } catch (e) {
      _errorMessage.value = 'Get me error: $e';
      print('❌ Exception: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _logoutUseCase.call();
    await _googleSignIn.signOut();
    _currentUser.value = null;
    _needProfile.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}
