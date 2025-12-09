import 'package:get/get.dart';
import 'package:pixel_love/features/pet_scene/domain/entities/pet_scene.dart';
import 'package:pixel_love/features/pet_scene/domain/usecases/get_pet_scene_usecase.dart';

class PetSceneController extends GetxController {
  final GetPetSceneUseCase _getPetSceneUseCase;

  PetSceneController(this._getPetSceneUseCase);

  final _isLoading = true.obs;
  final _errorMessage = ''.obs;
  final Rxn<PetScene> _petSceneData = Rxn<PetScene>();

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  PetScene? get petSceneData => _petSceneData.value;

  @override
  void onInit() {
    super.onInit();
    fetchPetScene();
  }

  Future<void> fetchPetScene() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _getPetSceneUseCase.call();

      result.when(
        success: (petScene) {
          _petSceneData.value = petScene;
          _isLoading.value = false;
          print('✅ Pet scene loaded: ${petScene.objects.length} objects');
        },
        error: (error) {
          _errorMessage.value = error.message;
          _isLoading.value = false;
          print('❌ Pet scene error: ${error.message}');
        },
      );
    } catch (e) {
      _errorMessage.value = 'Unexpected error: $e';
      _isLoading.value = false;
      print('❌ Pet scene exception: $e');
    }
  }
}
