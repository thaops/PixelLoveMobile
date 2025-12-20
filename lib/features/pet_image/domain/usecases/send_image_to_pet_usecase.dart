import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet_image/domain/repositories/pet_image_repository.dart';

class SendImageToPetUseCase {
  final PetImageRepository _repository;

  SendImageToPetUseCase(this._repository);

  Future<ApiResult<({
    int expAdded,
    int bonus,
    bool levelUp,
    String actionId,
  })>> call({
    required String imageUrl,
    DateTime? takenAt,
    String? text,
  }) {
    return _repository.sendImageToPet(
      imageUrl: imageUrl,
      takenAt: takenAt,
      text: text,
    );
  }
}

