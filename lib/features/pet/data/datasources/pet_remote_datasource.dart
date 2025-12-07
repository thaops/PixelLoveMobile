import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/pet/data/models/pet_dto.dart';

abstract class PetRemoteDataSource {
  Future<ApiResult<PetDto>> getPetStatus();
  Future<ApiResult<PetDto>> feedPet();
}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final DioApi _dioApi;

  PetRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<PetDto>> getPetStatus() async {
    return await _dioApi.get(
      '/pet/status',
      fromJson: (json) {
        final petData = json['pet'] ?? json;
        return PetDto.fromJson(petData);
      },
    );
  }

  @override
  Future<ApiResult<PetDto>> feedPet() async {
    return await _dioApi.post(
      '/pet/feed',
      data: {},
      fromJson: (json) {
        final petData = json['pet'] ?? json;
        return PetDto.fromJson(petData);
      },
    );
  }
}
