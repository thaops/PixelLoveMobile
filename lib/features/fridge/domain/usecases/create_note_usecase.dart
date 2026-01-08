import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/fridge/domain/repositories/fridge_repository.dart';

class CreateNoteUseCase {
  final FridgeRepository _repository;

  CreateNoteUseCase(this._repository);

  Future<ApiResult<void>> call(String content) {
    return _repository.createNote(content);
  }
}

