import 'package:pixel_love/features/watch_together/domain/repositories/watch_together_repository.dart';

class UpdateVideoUsecase {
  final WatchTogetherRepository _repository;

  UpdateVideoUsecase(this._repository);

  void call({required String type, required double time}) {
    _repository.updatePlayer(type: type, time: time);
  }
}