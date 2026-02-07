import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/radio/domain/entities/voice.dart';
import 'package:pixel_love/features/radio/providers/radio_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';

class RadioActionMenu extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final Rect radioRect;

  const RadioActionMenu({
    super.key,
    required this.onClose,
    required this.radioRect,
  });

  @override
  ConsumerState<RadioActionMenu> createState() => _RadioActionMenuState();
}

class _RadioActionMenuState extends ConsumerState<RadioActionMenu>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlayingPinned = false;
  int _recordDuration = 0;
  Timer? _timer;
  Voice? _pinnedVoice;
  bool _isLoadingPinned = true;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutBack,
    );
    _expandController.forward();
    _loadPinnedVoice();

    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlayingPinned = false);
    });
  }

  @override
  void dispose() {
    _expandController.dispose();
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadPinnedVoice() async {
    final dataSource = ref.read(radioRemoteDataSourceProvider);
    final result = await dataSource.getPinnedVoice();

    result.when(
      success: (voiceDto) {
        if (mounted) {
          setState(() {
            _pinnedVoice = voiceDto?.toEntity();
            _isLoadingPinned = false;
          });
        }
      },
      error: (_) {
        if (mounted) setState(() => _isLoadingPinned = false);
      },
    );
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần cấp quyền microphone'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final filePath =
        '${dir.path}/quick_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );

    setState(() {
      _isRecording = true;
      _recordDuration = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRecording) return;
      setState(() => _recordDuration++);
    });
  }

  bool _isSending = false;

  Future<void> _stopAndSendRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();

    setState(() {
      _isRecording = false;
    });

    if (path == null) return;

    // Set sending state locally
    setState(() => _isSending = true);

    try {
      final uploadService = ref.read(cloudinaryUploadServiceProvider);
      final file = File(path);
      final uploadResult = await uploadService.uploadAudio(file);

      await uploadResult.when(
        success: (audioUrl) async {
          final dataSource = ref.read(radioRemoteDataSourceProvider);
          final sendResult = await dataSource.sendVoice(
            audioUrl: audioUrl,
            duration: _recordDuration,
            takenAt: DateTime.now(),
            text: 'Quick voice ❤️',
            mood: 'love',
          );

          await sendResult.when(
            success: (response) async {
              await dataSource.pinVoice(response.actionId);

              if (mounted) {
                setState(() => _isSending = false);
                widget.onClose();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Đã ghi và ghim voice! +${response.expAdded} EXP'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            error: (error) {
              if (mounted) {
                setState(() => _isSending = false);
                // Removed pop since we don't have dialog anymore
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );
        },
        error: (error) {
          if (mounted) {
            setState(() => _isSending = false);
            // Removed pop since we don't have dialog anymore
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _togglePinnedPlayback() async {
    if (_pinnedVoice == null) return;

    if (_isPlayingPinned) {
      await _player.pause();
      setState(() => _isPlayingPinned = false);
    } else {
      await _player.play(UrlSource(_pinnedVoice!.audioUrl));
      setState(() => _isPlayingPinned = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menu width (điều chỉnh nhỏ hơn do bỏ padding)
    const menuWidth = 240.0;

    return ScaleTransition(
      scale: _expandAnimation,
      child: SizedBox(
        width: menuWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.list_rounded,
              label: 'List',
              color: const Color(0xFF4ECDC4),
              onTap: () {
                context.go(AppRoutes.radio);
              },
            ),
            _buildRecordButton(),
            _buildPlayPinnedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, // Nhỏ hơn
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          // const SizedBox(height: 4),
          // Text(
          //   label,
          //   style: const TextStyle(
          //     color: AppColors.buttonDisabledText,
          //     fontSize: 12,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: (_isRecording)
          ? _stopAndSendRecording
          : (_isSending ? null : _startRecording),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: (_isRecording || _isSending) ? 64 : 48,
            height: (_isRecording || _isSending) ? 64 : 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: (_isRecording || _isSending)
                    ? [const Color(0xFFFF4757), const Color(0xFFFF6B7A)]
                    : [AppColors.primaryPink, const Color(0xFFFF8E53)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      ((_isRecording || _isSending)
                              ? const Color(0xFFFF4757)
                              : AppColors.primaryPink)
                          .withOpacity(0.5),
                  blurRadius: (_isRecording || _isSending) ? 16 : 10,
                  spreadRadius: (_isRecording || _isSending) ? 3 : 1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isRecording)
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      value: null,
                      strokeWidth: 3,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                if (_isSending)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPinnedButton() {
    final hasPinned = _pinnedVoice != null;

    return GestureDetector(
      onTap: hasPinned ? _togglePinnedPlayback : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 48, // Nhỏ hơn
                height: 48,
                decoration: BoxDecoration(
                  gradient: hasPinned
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFD93D),
                            const Color(0xFFFF9F43),
                          ],
                        )
                      : null,
                  color: hasPinned ? null : Colors.grey.shade700,
                  shape: BoxShape.circle,
                  boxShadow: hasPinned
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFD93D).withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: _isLoadingPinned
                    ? const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        _isPlayingPinned
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white.withOpacity(hasPinned ? 1 : 0.5),
                        size: 24, // Nhỏ hơn
                      ),
              ),
              if (_isPlayingPinned)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 3,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          // const SizedBox(height: 4),
          // Text(
          //   hasPinned ? 'Phát ghim' : 'Chưa ghim',
          //   style: TextStyle(
          //     color: hasPinned ? Colors.white : Colors.white54,
          //     fontSize: 12,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
