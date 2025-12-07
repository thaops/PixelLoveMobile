import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet/domain/entities/pet.dart';
import 'package:pixel_love/features/pet/domain/repositories/pet_repository.dart';

class FeedPetUseCase {
  final PetRepository _repository;

  FeedPetUseCase(this._repository);

  Future<ApiResult<Pet>> call() {
    return _repository.feedPet();
  }
}
