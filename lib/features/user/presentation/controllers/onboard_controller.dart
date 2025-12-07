import 'package:get/get.dart';
import 'package:pixel_love/features/user/domain/usecases/onboard_usecase.dart';
import 'package:pixel_love/routes/app_routes.dart';

class OnboardController extends GetxController {
  final OnboardUseCase _onboardUseCase;

  OnboardController(this._onboardUseCase);

  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _selectedGender = Rxn<String>();
  final _selectedBirthDate = Rxn<DateTime>();
  final _nickname = ''.obs;

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String? get selectedGender => _selectedGender.value;
  DateTime? get selectedBirthDate => _selectedBirthDate.value;
  String get nickname => _nickname.value;

  bool get canSubmit =>
      _nickname.value.trim().isNotEmpty &&
      _selectedGender.value != null &&
      _selectedBirthDate.value != null;

  void setGender(String gender) {
    _selectedGender.value = gender;
  }

  void setBirthDate(DateTime date) {
    _selectedBirthDate.value = date;
  }

  void setNickname(String value) {
    _nickname.value = value;
    update();
  }

  Future<void> submit() async {
    if (!canSubmit) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng điền đầy đủ thông tin',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final birthDateString =
          '${_selectedBirthDate.value!.year}-${_selectedBirthDate.value!.month.toString().padLeft(2, '0')}-${_selectedBirthDate.value!.day.toString().padLeft(2, '0')}';

      print(
        '📝 Onboarding: nickname=${_nickname.value}, gender=${_selectedGender.value}, birthDate=$birthDateString',
      );

      final result = await _onboardUseCase.call(
        nickname: _nickname.value.trim(),
        gender: _selectedGender.value!,
        birthDate: birthDateString,
      );

      result.when(
        success: (user) {
          print('✅ Onboard success: ${user.name}');

          // Navigate to couple connection screen
          Get.offAllNamed(AppRoutes.coupleConnection);

          Get.snackbar(
            'Thành công',
            'Chào mừng ${user.name}!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        error: (error) {
          _errorMessage.value = error.message;
          Get.snackbar(
            'Lỗi',
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
