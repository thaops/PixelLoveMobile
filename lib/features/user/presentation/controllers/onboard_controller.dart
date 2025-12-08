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
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final birthDateString =
          '${_selectedBirthDate.value!.year}-${_selectedBirthDate.value!.month.toString().padLeft(2, '0')}-${_selectedBirthDate.value!.day.toString().padLeft(2, '0')}';

      final result = await _onboardUseCase.call(
        nickname: _nickname.value.trim(),
        gender: _selectedGender.value!,
        birthDate: birthDateString,
      );

      result.when(
        success: (user) {
          Get.offAllNamed(AppRoutes.coupleConnection);
        },
        error: (error) {
          _errorMessage.value = error.message;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
