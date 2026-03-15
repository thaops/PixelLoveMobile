import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pixel_love/features/audio_player/domain/entities/track.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  // Callbacks to notify the notifier when lock screen actions happen
  Function()? onPauseRequested;
  Function()? onPlayRequested;
  Function()? onSkipNextRequested;
  Function()? onSkipPreviousRequested;
  Function(Duration)? onSeekRequested;

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    // Nghe trạng thái với debounce nhẹ hoặc check distinct
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
      _broadcastState();
    });

    // Nghe các sự kiện seek/buffering, giới hạn tần suất cập nhật
    _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
  }

  void _broadcastState() {
    final playing = _player.playing;
    final state = playbackState.value;

    final newProcessingState = const {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    }[_player.processingState]!;

    // Chỉ cập nhật nếu có sự thay đổi thực tế về trạng thái hoặc vị trí đáng kể
    if (state.playing == playing &&
        state.processingState == newProcessingState &&
        (state.updatePosition - _player.position).abs() <
            const Duration(milliseconds: 500)) {
      return;
    }

    playbackState.add(
      state.copyWith(
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
        processingState: newProcessingState,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
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

  @override
  Future<void> skipToPrevious() async {
    if (onSkipPreviousRequested != null) {
      onSkipPreviousRequested!();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
    await super.stop();
  }

  // Helper methods for the Notifier
  Future<void> setAudioUrl(String url) async {
    try {
      // Sử dụng 'preload: false' nếu muốn lướt qua nhanh mà không block luồng
      // Nhưng ở đây ta muốn phát ngay nên để mặc định, chỉ thêm catch error
      await _player.setUrl(url);
    } catch (e) {
      print("Error setting audio URL: $e");
    }
  }

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
