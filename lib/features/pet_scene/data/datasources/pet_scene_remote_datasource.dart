import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/pet_scene/data/models/pet_scene_dto.dart';

abstract class PetSceneRemoteDataSource {
  Future<ApiResult<PetSceneDto>> getPetScene();
}

class PetSceneRemoteDataSourceImpl implements PetSceneRemoteDataSource {
  final DioApi _dioApi;

  PetSceneRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<PetSceneDto>> getPetScene() async {
    return await _dioApi.get(
      '/pet/scene',
      fromJson: (json) => PetSceneDto.fromJson(json),
    );
  }
}
