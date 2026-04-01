import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/watch_together/data/models/video_item_dto.dart';
import 'package:pixel_love/features/watch_together/data/models/video_room_state_dto.dart';
import 'package:pixel_love/features/watch_together/domain/entities/video_player_state.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/add_video_usecase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/get_video_usercase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/init_player_usecase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/next_video_usecase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/remove_video_usecase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/send_ended_usecase.dart';
import 'package:pixel_love/features/watch_together/domain/usecases/update_video_usecase.dart';
import 'package:pixel_love/features/watch_together/providers/watch_together_providers.dart';

class WatchTogetherUIState {
  final VideoPlayerState? roomState;
  final bool isLoading;
  final String? errorMessage;
  final double? pendingSeekTo;

  const WatchTogetherUIState({
    this.roomState,
    this.isLoading = false,
    this.errorMessage,
    this.pendingSeekTo,
  });

  WatchTogetherUIState copyWith({
    VideoPlayerState? roomState,
    bool? isLoading,
    String? errorMessage,
    double? pendingSeekTo,
    bool clearError = false,
    bool clearSeek = false,
  }) {
    return WatchTogetherUIState(
      roomState: roomState ?? this.roomState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingSeekTo: clearSeek ? null : (pendingSeekTo ?? this.pendingSeekTo),
    );
  }
}

class WatchTogetherNotifier extends Notifier<WatchTogetherUIState> {
  late final GetVideoUsercase _getVideoState;
  late final AddVideoUsecase _addVideo;
  late final RemoveVideoUsecase _removeVideo;
  late final UpdateVideoUsecase _updatePlayer;
  late final NextVideoUsecase _nextVideo;
  late final SendEndedUsecase _sendEnded;
  late final InitPlayerUsecase _initPlayer;

  bool _isHandlingServerEvent = false;

  @override
  WatchTogetherUIState build() {
    _getVideoState = ref.watch(getVideoStateUseCaseProvider);
    _addVideo = ref.watch(addVideoUseCaseProvider);
    _removeVideo = ref.watch(removeVideoUseCaseProvider);
    _updatePlayer = ref.watch(updateVideoUseCaseProvider);
    _nextVideo = ref.watch(nextVideoUseCaseProvider);
    _sendEnded = ref.watch(sendEndedUseCaseProvider);
    _initPlayer = ref.watch(initPlayerUseCaseProvider);

    _registerSocketCallbacks();
    ref.onDispose(_clearSocketCallbacks);
    // Init room session trước, sau đó load state
    Future.microtask(_initAndLoad);

    return const WatchTogetherUIState(isLoading: true);
  }

  void _registerSocketCallbacks() {
    final socket = ref.read(socketServiceProvider);

    socket.onPlayerState = (data) {
      _isHandlingServerEvent = true;
      final entity = VideoRoomStateDto.fromJson(data).toEntity();
      final seekTo = _syncedTime(entity.currentTime, entity.serverTime, entity.isPlaying);
      state = state.copyWith(
        roomState: entity,
        isLoading: false,
        pendingSeekTo: seekTo,
      );
      _isHandlingServerEvent = false;
    };

    socket.onPlayerVideoUpdate = (data) {
      _isHandlingServerEvent = true;
      final current = state.roomState;
      if (current == null) {
        _isHandlingServerEvent = false;
        return;
      }
      final type = data['type'] as String?;
      final rawTime = (data['currentTime'] as num?)?.toDouble() ?? current.currentTime;
      final serverTime = data['serverTime'] as int?;
      final videoId = data['videoId'] as String? ?? current.videoId;
      final currentId = data['currentId'] as String? ?? current.currentId;
      final syncedTime = _syncedTime(rawTime, serverTime, type == 'play');

      state = state.copyWith(
        roomState: current.copyWith(
          isPlaying: type == 'play',
          currentTime: syncedTime,
          videoId: videoId,
          currentId: currentId,
        ),
        pendingSeekTo: (type == 'seek' || type == 'play') ? syncedTime : null,
      );
      _isHandlingServerEvent = false;
    };

    socket.onPlayerQueueUpdated = (data) {
      final current = state.roomState;
      if (current == null) return;
      final rawQueue = data['queue'] as List<dynamic>? ?? [];
      final queue = rawQueue
          .map((e) => VideoItemDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      state = state.copyWith(
        roomState: current.copyWith(
          videoItems: queue,
          currentIndex: data['currentIndex'] as int? ?? current.currentIndex,
          currentId: data['currentId'] as String? ?? current.currentId,
        ),
      );
    };
  }

  void _clearSocketCallbacks() {
    final socket = ref.read(socketServiceProvider);
    socket.onPlayerState = null;
    socket.onPlayerVideoUpdate = null;
    socket.onPlayerQueueUpdated = null;
  }

  double _syncedTime(double rawTime, int? serverTime, bool isPlaying) {
    if (serverTime == null || !isPlaying) return rawTime;
    final now = DateTime.now().millisecondsSinceEpoch;
    return rawTime + ((now - serverTime) / 1000.0);
  }

  Future<void> _initAndLoad() async {
    final storage = ref.read(storageServiceProvider);
    final user = storage.getUser();
    final roomId = user?.coupleRoomId;

    final socket = ref.read(socketServiceProvider);
    final connected = await socket.connectEvents(); // Chờ kết nối thành công

    if (connected && roomId != null) {
      socket.joinCoupleRoom(roomId); // Định danh couple room
      socket.emitPlayerEnter(); // Gửi tín hiệu enter room
      _initPlayer(null); // Gửi init player session
    }

    await Future.delayed(const Duration(seconds: 1)); // Cho server thêm thời gian xử lý metadata
    await loadState();
  }

  Future<void> loadState() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getVideoState();
    result.when(
      success: (roomState) {
        final seekTo = _syncedTime(
          roomState.currentTime,
          roomState.serverTime,
          roomState.isPlaying,
        );
        state = state.copyWith(
          roomState: roomState,
          isLoading: false,
          pendingSeekTo: seekTo,
        );
      },
      error: (e) => state = state.copyWith(isLoading: false, errorMessage: e.message),
    );
  }

  Future<void> addVideo(String url) async {
    if (url.trim().isEmpty) return;
    final result = await _addVideo(url.trim());
    result.when(
      success: (_) {},
      error: (e) => state = state.copyWith(errorMessage: e.message),
    );
  }

  Future<void> removeVideo(String itemId) async {
    final result = await _removeVideo(itemId);
    result.when(
      success: (_) {},
      error: (e) => state = state.copyWith(errorMessage: e.message),
    );
  }

  void sendPlayPause({required bool currentIsPlaying, required double time}) {
    if (_isHandlingServerEvent) return;
    _updatePlayer(type: currentIsPlaying ? 'pause' : 'play', time: time);
  }

  void sendSeek(double time) {
    if (_isHandlingServerEvent) return;
    _updatePlayer(type: 'seek', time: time);
  }

  void nextVideo() => _nextVideo();

  void onVideoEnded() => _sendEnded();

  void clearPendingSeek() => state = state.copyWith(clearSeek: true);

  void clearError() => state = state.copyWith(clearError: true);
}