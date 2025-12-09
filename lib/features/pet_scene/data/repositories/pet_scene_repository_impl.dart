import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet_scene/data/datasources/pet_scene_remote_datasource.dart';
import 'package:pixel_love/features/pet_scene/domain/entities/pet_scene.dart';
import 'package:pixel_love/features/pet_scene/domain/repositories/pet_scene_repository.dart';

class PetSceneRepositoryImpl implements PetSceneRepository {
  final PetSceneRemoteDataSource _remoteDataSource;

  PetSceneRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<PetScene>> getPetScene() async {
    final result = await _remoteDataSource.getPetScene();

    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (error) => ApiResult.error(error),
    );
  }
}
