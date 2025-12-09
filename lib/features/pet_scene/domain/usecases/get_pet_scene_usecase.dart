import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet_scene/domain/entities/pet_scene.dart';
import 'package:pixel_love/features/pet_scene/domain/repositories/pet_scene_repository.dart';

class GetPetSceneUseCase {
  final PetSceneRepository _repository;

  GetPetSceneUseCase(this._repository);

  Future<ApiResult<PetScene>> call() {
    return _repository.getPetScene();
  }
}
