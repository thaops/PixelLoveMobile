import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/watch_together/domain/repositories/watch_together_repository.dart';

class AddVideoUsecase {
  final WatchTogetherRepository _repository;

  AddVideoUsecase(this._repository);

  Future<ApiResult<bool>> call(String url) {
    return _repository.addVideo(url);
  }
}