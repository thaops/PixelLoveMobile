import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YtControllerNotifier extends Notifier<YoutubePlayerController?> {
  @override
  YoutubePlayerController? build() => null;

  void setController(YoutubePlayerController ctrl) {
    state = ctrl;
  }

  void clear() {
    state = null;
  }
}
