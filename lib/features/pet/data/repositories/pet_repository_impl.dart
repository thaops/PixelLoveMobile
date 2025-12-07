import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:pixel_love/features/pet/domain/entities/pet.dart';
import 'package:pixel_love/features/pet/domain/repositories/pet_repository.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource _remoteDataSource;

  PetRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<Pet>> getPetStatus() async {
    final result = await _remoteDataSource.getPetStatus();

    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (error) => ApiResult.error(error),
    );
  }

  @override
  Future<ApiResult<Pet>> feedPet() async {
    final result = await _remoteDataSource.feedPet();

    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (error) => ApiResult.error(error),
    );
  }
}
