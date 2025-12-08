import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pixel_love/core/services/socket_service.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/user/domain/usecases/delete_account_usecase.dart';
import 'package:pixel_love/routes/app_routes.dart';

class SettingsController extends GetxController {
  final DeleteAccountUseCase _deleteAccountUseCase;
  final StorageService _storageService;
  final SocketService _socketService;

  SettingsController(
    this._deleteAccountUseCase,
    this._storageService,
    this._socketService,
  );

  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final user = _storageService.getUser();
      if (user == null) {
        _errorMessage.value = 'Không tìm thấy thông tin người dùng';
        return;
      }

      final result = await _deleteAccountUseCase.call(user.id);

      if (result.isSuccess) {
        // Sign out from Google
        await _googleSignIn.signOut();
        // Disconnect socket
        _socketService.disconnectEvents();
        // Clear all data
        await _storageService.clearAll();
        // Navigate to login
        Get.offAllNamed(AppRoutes.login);
      } else if (result.error != null) {
        _errorMessage.value = result.error!.message;
      }
    } catch (e) {
      _errorMessage.value = 'Lỗi xóa tài khoản: $e';
    } finally {
      _isLoading.value = false;
    }
  }
}

