import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/domain/repositories/pet_image_repository.dart';

class GetPetImagesUseCase {
  final PetImageRepository _repository;

  GetPetImagesUseCase(this._repository);

  Future<ApiResult<({List<PetImage> items, int total})>> call({
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getPetImages(page: page, limit: limit);
  }
}

