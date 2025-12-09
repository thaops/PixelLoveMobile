import 'package:get/get.dart';
import 'package:pixel_love/features/pet/domain/entities/pet.dart';
import 'package:pixel_love/features/pet/domain/usecases/feed_pet_usecase.dart';
import 'package:pixel_love/features/pet/domain/usecases/get_pet_status_usecase.dart';

class PetController extends GetxController {
  final GetPetStatusUseCase _getPetStatusUseCase;
  final FeedPetUseCase _feedPetUseCase;
  final bool _autoFetch;

  PetController(
    this._getPetStatusUseCase,
    this._feedPetUseCase, {
    bool autoFetch = true,
  }) : _autoFetch = autoFetch;

  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final Rxn<Pet> _pet = Rxn<Pet>();

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  Pet? get pet => _pet.value;

  // Check if on cooldown (from backend data)
  bool get canFeed {
    final petData = _pet.value;
    if (petData == null) return false;

    // Backend should provide cooldown info in pet object
    // For now, check if not already feeding
    return !_isLoading.value;
  }

  @override
  void onInit() {
    super.onInit();
    // Chỉ auto-fetch nếu được set flag autoFetch = true
    // Khi vào home, HomeController sẽ gọi fetchPetStatus() sau khi home data load xong
    if (_autoFetch) {
      fetchPetStatus();
    }
    // Note: Socket updates will trigger UI refresh via PetScreen pull-to-refresh
    // or manual refresh when user views the screen
  }

  Future<void> fetchPetStatus() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _getPetStatusUseCase.call();

      result.when(
        success: (pet) {
          _pet.value = pet;
          print('✅ Pet status: level=${pet.level}, hunger=${pet.hunger}');
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

  Future<void> feedPet() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _feedPetUseCase.call();

      result.when(
        success: (pet) {
          _pet.value = pet;
          print('✅ Pet fed successfully');

          Get.snackbar(
            'Success',
            'Pet fed successfully! 🍖',
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

  double get expProgress {
    if (pet == null) return 0.0;
    return pet!.exp / pet!.maxExp;
  }
}
