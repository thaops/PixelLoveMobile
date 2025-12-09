import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet_scene/domain/entities/pet_scene.dart';

abstract class PetSceneRepository {
  Future<ApiResult<PetScene>> getPetScene();
}
