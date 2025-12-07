import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet/domain/entities/pet.dart';

abstract class PetRepository {
  Future<ApiResult<Pet>> getPetStatus();
  Future<ApiResult<Pet>> feedPet();
}
