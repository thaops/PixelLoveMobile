import 'package:pixel_love/features/watch_together/domain/repositories/watch_together_repository.dart';

class InitPlayerUsecase {
  final WatchTogetherRepository _repository;

  InitPlayerUsecase(this._repository);

  void call(String? videoId, {bool resetQueue = false}) {
    _repository.initPlayer(videoId, resetQueue: resetQueue);
  }
}