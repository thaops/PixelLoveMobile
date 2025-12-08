import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pixel_love/core/services/socket_service.dart';
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
  final SocketService _socketService;

  AuthController(
    this._loginGoogleUseCase,
    this._getMeUseCase,
    this._logoutUseCase,
    this._storageService,
    this._socketService,
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

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _errorMessage.value = 'Google sign in cancelled';
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        _errorMessage.value = 'Failed to get Google access token';
        return;
      }

      final result = await _loginGoogleUseCase.call(idToken);

      if (result.isSuccess && result.data != null) {
        final response = result.data!;

        await _storageService.saveToken(response.token);

        _currentUser.value = response.user;
        await _storageService.saveUser(response.user);
        _needProfile.value = response.needProfile;

        await _socketService.connectEvents();

        if (response.needProfile) {
          Get.offAllNamed(AppRoutes.onboard);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      } else if (result.error != null) {
        _errorMessage.value = result.error!.message;
      }
    } catch (e) {
      _errorMessage.value = 'Google login error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> getMe() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _getMeUseCase.call();

      result.when(
        success: (user) {
          _currentUser.value = user;
          _storageService.saveUser(user);
        },
        error: (error) {
          _errorMessage.value = error.message;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Get me error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _logoutUseCase.call();
    await _googleSignIn.signOut();
    _socketService.disconnectEvents();
    _currentUser.value = null;
    _needProfile.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}
