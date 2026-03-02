import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/services/socket_service.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:pixel_love/features/audio_player/domain/entities/audio_player_state.dart';
import 'package:pixel_love/features/audio_player/domain/entities/track.dart';
import 'package:pixel_love/features/audio_player/domain/repositories/audio_repository.dart';
import 'package:pixel_love/features/user/providers/user_providers.dart';
import 'package:pixel_love/features/couple/providers/couple_providers.dart';

import 'package:pixel_love/features/audio_player/providers/audio_providers.dart';
import 'audio_handler.dart';

class AudioPlayerNotifier extends Notifier<AudioPlayerState>
    with WidgetsBindingObserver {
  late final MyAudioHandler _audioHandler;
  Timer? _ticker;
  bool _isCommandPending = false;
  bool get isCommandPending => _isCommandPending;

  @override
  AudioPlayerState build() {
    _audioHandler = ref.watch(audioHandlerProvider);

    // Đăng ký lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Khởi tạo Audio Session & Sync
    Future.microtask(() => _setup());

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _ticker?.cancel();
    });

    return AudioPlayerState(
      currentTrack: null,
      isPlaying: false,
      currentTime: 0,
      queue: const [],
    );
  }

  AudioRepository get _repository => ref.read(audioRepositoryProvider);
  SocketService get _socketService => ref.read(socketServiceProvider);

  Future<void> _setup() async {
    // 1. Cấu hình Audio Session cho iOS/Android Background
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // 2. Kết nối Socket & Listeners
    await _socketService.connectEvents();
    _setupSocketListeners();
    _attachAudioHandlerCallbacks();

    // 2.5 Manual Join Room (Đảm bảo nhận được Socket Event)
    final currentUser = ref.read(userNotifierProvider).currentUser;
    if (currentUser?.coupleRoomId != null) {
      _socketService.joinCoupleRoom(currentUser!.coupleRoomId!);
    }

    // 3. Lấy trạng thái ban đầu
    await fetchState();

    // 4. Lấy avatar của partner nếu ở chế độ couple
    _fetchPartnerAvatar();
  }

  Future<void> _fetchPartnerAvatar() async {
    final currentUser = ref.read(userNotifierProvider).currentUser;
    if (currentUser?.mode == 'couple' &&
        currentUser?.coupleRoomId != null &&
        currentUser!.coupleRoomId!.isNotEmpty) {
      final getCoupleInfoUseCase = ref.read(getCoupleInfoUseCaseProvider);
      final result = await getCoupleInfoUseCase.call();
      result.when(
        success: (data) {
          final userA = data['userA'] as Map<String, dynamic>?;
          final userB = data['userB'] as Map<String, dynamic>?;

          Map<String, dynamic>? partner;
          if (userA != null && userA['userId'] != currentUser.id) {
            partner = userA;
          } else if (userB != null && userB['userId'] != currentUser.id) {
            partner = userB;
          }

          if (partner != null) {
            final avatar =
                partner['avatarUrl']?.toString() ??
                partner['avatar']?.toString();
            final name =
                partner['nickname']?.toString() ??
                partner['displayName']?.toString();

            state = state.copyWith(partnerAvatar: avatar, partnerName: name);
            print('💕 Partner Info Sync: $name, Avatar: $avatar');
          }
        },
        error: (failure) => print('⚠️ Fetch partner avatar failed: $failure'),
      );
    }
  }

  void _attachAudioHandlerCallbacks() {
    // Intercept Lock Screen actions and redirect to API
    _audioHandler.onPlayRequested = () {
      if (state.currentTrack != null) playTrack(state.currentTrack!.id);
    };
    _audioHandler.onPauseRequested = () => pauseTrack();
    _audioHandler.onSkipNextRequested = () => next();
    _audioHandler.onSeekRequested = (duration) => seek(duration.inSeconds);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Khi quay lại app, LUÔN LUÔN fetch state mới nhất từ server
      print('📱 App resumed, syncing audio state...');
      fetchState();
    }
  }

  void _setupSocketListeners() {
    _socketService.onPlayerUpdate = (data) {
      final type = data['type'] as String?;
      final trackId = data['currentTrackId'] as String?;
      final isPlaying = data['isPlaying'] as bool?;
      final currentTime = (data['currentTime'] as num? ?? 0).toDouble();

      print(
        '🎵 Socket Event [$type]: Track=$trackId, Playing=$isPlaying, Time=$currentTime',
      );

      // 1. Kiểm tra nếu chuyển bài
      if (trackId != null &&
          (state.currentTrack == null || state.currentTrack!.id != trackId)) {
        final trackInQueue = state.queue
            .where((t) => t.id == trackId)
            .firstOrNull;

        if (trackInQueue != null) {
          print(
            '✅ Found track in local queue, updating and loading immediately',
          );
          state = state.copyWith(
            currentTrack: trackInQueue,
            isPlaying: isPlaying ?? state.isPlaying,
            currentTime: currentTime,
            isLoading: true, // Bật loading khi đổi bài
          );
          _playLocal(trackInQueue);
          return;
        } else {
          print('🔍 Track not in local queue, fetching full state from server');
          state = state.copyWith(isLoading: true);
          fetchState();
          return;
        }
      }

      // 2. Nếu cùng bài, đồng bộ trạng thái
      if (isPlaying != null) {
        state = state.copyWith(
          isPlaying: isPlaying,
          currentTime: currentTime,
          isLoading: false, // Tắt loading khi đã sync xong
        );

        if (isPlaying) {
          _audioHandler.playbackPlay();
        } else {
          _audioHandler.playbackPause();
        }

        final localPos = _audioHandler.position.inSeconds;
        if ((localPos - currentTime).abs() > 1.5) {
          _audioHandler.playbackSeek(Duration(seconds: currentTime.toInt()));
        }

        _handleTicker();
      }
    };

    _socketService.onQueueUpdate = (data) {
      final type = data['type'] as String?;
      final trackData = data['track'] as Map<String, dynamic>?;

      if (type == 'added' && trackData != null) {
        // Instant sync: Thêm ngay vào list local để User thấy 'Processing'
        final newTrack = Track(
          id: data['trackId'] ?? '',
          title: trackData['title'] ?? 'Processing...',
          thumbnail: trackData['thumbnail'] ?? '',
          audioUrl: trackData['audioUrl'] ?? '',
          duration: trackData['duration'] ?? 0,
          status: 'processing',
          progress: 0,
        );

        // Tránh trùng lặp nếu mình chính là người add
        if (!state.queue.any((t) => t.id == newTrack.id)) {
          state = state.copyWith(queue: [...state.queue, newTrack]);
        }
      } else if (type == 'ready') {
        // Khi nhạc xong (100%), cập nhật lại item đó trong list
        final updatedQueue = state.queue.map((t) {
          if (t.id == data['trackId']) {
            final readyTrack = trackData != null
                ? Track(
                    id: t.id,
                    title: trackData['title'] ?? t.title,
                    thumbnail: trackData['thumbnail'] ?? t.thumbnail,
                    audioUrl: trackData['audioUrl'] ?? t.audioUrl,
                    duration: trackData['duration'] ?? t.duration,
                    status: 'ready',
                    progress: 100,
                  )
                : Track(
                    id: t.id,
                    title: t.title,
                    thumbnail: t.thumbnail,
                    audioUrl: data['audioUrl'] ?? t.audioUrl,
                    duration: t.duration,
                    status: 'ready',
                    progress: 100,
                  );
            return readyTrack;
          }
          return t;
        }).toList();
        state = state.copyWith(queue: updatedQueue);
      } else {
        updateQueue();
      }
    };

    _socketService.onQueueProgress = (data) {
      final trackId = data['trackId'] as String?;
      final progress = data['progress'] as int?;

      if (trackId != null && progress != null) {
        final updatedQueue = state.queue.map((t) {
          if (t.id == trackId) {
            return Track(
              id: t.id,
              title: t.title,
              thumbnail: t.thumbnail,
              audioUrl: t.audioUrl,
              duration: t.duration,
              status: progress >= 100 ? 'ready' : 'processing',
              progress: progress,
            );
          }
          return t;
        }).toList();
        state = state.copyWith(queue: updatedQueue);
      }
    };

    _socketService.onServerConnected = (data) {
      final connectedUserId = data['userId'] as String?;
      final currentUser = ref.read(userNotifierProvider).currentUser;

      if (connectedUserId != null && connectedUserId == currentUser?.id) {
        // Nếu là chính mình vừa kết nối, re-join phòng để chắc chắn
        if (currentUser?.coupleRoomId != null) {
          _socketService.joinCoupleRoom(currentUser!.coupleRoomId!);
        }
      }

      if (connectedUserId != null &&
          connectedUserId == currentUser?.partnerId) {
        print('💕 Partner connected: $connectedUserId');
        state = state.copyWith(isPartnerOnline: true);
      }
    };

    _socketService.onPlayerTimerUpdate = (data) {
      final timerEndsAt = data['timerEndsAt'] as String?;
      print('🎵 Timer update from socket: $timerEndsAt');
      state = state.copyWith(timerEndsAt: timerEndsAt);
    };
  }

  Future<void> fetchState() async {
    final result = await _repository.getPlayerState();
    result.when(
      success: (data) {
        final oldTrack = state.currentTrack;
        // Lưu trữ thông tin partner hiện tại trước khi cập nhật state mới từ server
        final currentPartnerAvatar = state.partnerAvatar;
        final currentPartnerName = state.partnerName;
        final currentIsPartnerOnline = state.isPartnerOnline;

        state = data.copyWith(
          partnerAvatar: currentPartnerAvatar,
          partnerName: currentPartnerName,
          isPartnerOnline: currentIsPartnerOnline,
        );

        if (state.currentTrack != null) {
          _audioHandler.updateMetadata(state.currentTrack!);

          if (oldTrack?.id != state.currentTrack?.id) {
            _playLocal(state.currentTrack!);
          } else {
            // Drift Correction: Nếu lệch > 1 giây thì sync ngay
            final localPos = _audioHandler.position.inSeconds;
            if ((localPos - state.currentTime).abs() > 1) {
              _audioHandler.playbackSeek(
                Duration(seconds: state.currentTime.toInt()),
              );
            }
          }

          if (state.isPlaying) {
            _audioHandler.playbackPlay();
          } else {
            _audioHandler.playbackPause();
          }
        } else {
          _audioHandler.playbackStop();
        }

        _handleTicker();
      },
      error: (error) {
        print('Error fetching player state: ${error.message}');
      },
    );
  }

  Future<void> _playLocal(Track track) async {
    try {
      print('💿 Loading audio URL: ${track.audioUrl}');
      state = state.copyWith(isLoading: true);

      await _audioHandler.setAudioUrl(track.audioUrl);

      if (state.currentTime > 0) {
        await _audioHandler.playbackSeek(
          Duration(seconds: state.currentTime.toInt()),
        );
      }

      state = state.copyWith(isLoading: false);

      if (state.isPlaying) {
        _audioHandler.playbackPlay();
      }
    } catch (e) {
      print('❌ Error loading music: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void _handleTicker() {
    _ticker?.cancel();
    if (state.isPlaying) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
        state = state.copyWith(currentTime: state.currentTime + 1);
      });
    }
  }

  Future<void> playTrack(String trackId) async {
    if (_isCommandPending) return;
    _setCommandPending(true);

    // Mobile không tự quyết định thời gian phát, để Server (SSoT) xử lý logic Resume
    await _repository.playTrack(trackId);
    _setCommandPending(false);
  }

  Future<void> pauseTrack() async {
    if (_isCommandPending) return;
    _setCommandPending(true);
    await _repository.pauseTrack();
    _setCommandPending(false);
  }

  Future<void> seek(num time) async {
    // API Call
    await _repository.seekTrack(time);
  }

  Future<void> next() async {
    if (_isCommandPending) return;
    _setCommandPending(true);
    await _repository.nextTrack();
    _setCommandPending(false);
  }

  Future<void> previous() async {
    if (_isCommandPending) return;
    _setCommandPending(true);

    if (state.currentTime > 5) {
      await seek(0);
    } else {
      await _repository.previousTrack();
    }

    _setCommandPending(false);
  }

  void _setCommandPending(bool value) {
    _isCommandPending = value;
  }

  Future<void> addTrack(String youtubeUrl) async {
    await _repository.addTrack(youtubeUrl);
  }

  Future<void> removeTrack(String trackId) async {
    await _repository.removeTrack(trackId);
  }

  Future<void> updateQueue() async {
    final result = await _repository.getQueue();
    result.when(
      success: (queue) => state = state.copyWith(queue: queue),
      error: (_) => null,
    );
  }

  Future<void> setTimer(int minutes) async {
    await _repository.setTimer(minutes);
  }
}
