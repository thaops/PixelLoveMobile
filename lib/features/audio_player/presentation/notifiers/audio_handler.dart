import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pixel_love/features/audio_player/domain/entities/track.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  // Callbacks to notify the notifier when lock screen actions happen
  Function()? onPauseRequested;
  Function()? onPlayRequested;
  Function()? onSkipNextRequested;
  Function(Duration)? onSeekRequested;

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });

    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 3],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: event.currentIndex,
        ),
      );
    });
  }

  @override
  Future<void> play() async {
    if (onPlayRequested != null) {
      onPlayRequested!();
    } else {
      await _player.play();
    }
  }

  @override
  Future<void> pause() async {
    if (onPauseRequested != null) {
      onPauseRequested!();
    } else {
      await _player.pause();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (onSeekRequested != null) {
      onSeekRequested!(position);
    } else {
      await _player.seek(position);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (onSkipNextRequested != null) {
      onSkipNextRequested!();
    }
  }

  // Helper methods for the Notifier
  Future<void> setAudioUrl(String url) => _player.setUrl(url);
  Future<void> playbackPlay() => _player.play();
  Future<void> playbackPause() => _player.pause();
  Future<void> playbackStop() => _player.stop();
  Future<void> playbackSeek(Duration duration) => _player.seek(duration);
  Duration get position => _player.position;

  void updateMetadata(Track track) {
    mediaItem.add(
      MediaItem(
        id: track.id,
        album: "PixelLove Duo",
        title: track.title,
        artist: "Syncing with Partner",
        duration: Duration(seconds: track.duration.toInt()),
        artUri: Uri.parse(track.thumbnail),
      ),
    );
  }
}
