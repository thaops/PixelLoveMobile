import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet_image/data/datasources/pet_image_remote_datasource.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/domain/repositories/pet_image_repository.dart';

class PetImageRepositoryImpl implements PetImageRepository {
  final PetImageRemoteDataSource _remoteDataSource;

  PetImageRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<({List<PetImage> items, int total})>> getPetImages({
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _remoteDataSource.getPetImages(
      page: page,
      limit: limit,
    );

    return result.when(
      success: (dto) => ApiResult.success((
        items: dto.items.map((item) => item.toEntity()).toList(),
        total: dto.total,
      )),
      error: (failure) => ApiResult.error(failure),
    );
  }

  @override
  Future<ApiResult<({
    int expAdded,
    int bonus,
    bool levelUp,
    String actionId,
  })>> sendImageToPet({
    required String imageUrl,
    DateTime? takenAt,
    String? text,
  }) async {
    final result = await _remoteDataSource.sendImageToPet(
      imageUrl: imageUrl,
      takenAt: takenAt?.toIso8601String(),
      text: text,
    );

    return result.when(
      success: (dto) => ApiResult.success((
        expAdded: dto.expAdded,
        bonus: dto.bonus,
        levelUp: dto.levelUp,
        actionId: dto.actionId,
      )),
      error: (failure) => ApiResult.error(failure),
    );
  }
}

