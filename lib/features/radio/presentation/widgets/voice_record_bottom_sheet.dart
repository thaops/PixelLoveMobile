import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/radio/providers/radio_providers.dart';

class VoiceRecordBottomSheet extends ConsumerStatefulWidget {
  const VoiceRecordBottomSheet({super.key});

  @override
  ConsumerState<VoiceRecordBottomSheet> createState() =>
      _VoiceRecordBottomSheetState();
}

class _VoiceRecordBottomSheetState extends ConsumerState<VoiceRecordBottomSheet>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isUploading = false;
  bool _isPreviewPlaying = false;
  String? _recordedFilePath;
  int _recordDuration = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _selectedMood = 'love';
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {
      'value': 'love',
      'emoji': '❤️',
      'label': 'Love',
      'color': const Color(0xFFFF6B9D),
    },
    {
      'value': 'happy',
      'emoji': '😊',
      'label': 'Happy',
      'color': const Color(0xFFFFD93D),
    },
    {
      'value': 'sad',
      'emoji': '😢',
      'label': 'Sad',
      'color': const Color(0xFF6BCB77),
    },
    {
      'value': 'neutral',
      'emoji': '😐',
      'label': 'Neutral',
      'color': const Color(0xFF4ECDC4),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPreviewPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần cấp quyền microphone để ghi âm'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final filePath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

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
      _recordedFilePath = filePath;
      _recordDuration = 0;
    });

    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_isRecording) return;
      setState(() {
        _recordDuration++;
      });
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    final path = await _recorder.stop();

    setState(() {
      _isRecording = false;
      _recordedFilePath = path;
    });
  }

  Future<void> _togglePreview() async {
    if (_recordedFilePath == null) return;

    if (_isPreviewPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPreviewPlaying = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
      setState(() => _isPreviewPlaying = true);
    }
  }

  Future<void> _stopPreview() async {
    await _audioPlayer.stop();
    setState(() => _isPreviewPlaying = false);
  }

  Future<void> _uploadAndSend() async {
    if (_recordedFilePath == null) return;
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tin nhắn đi kèm'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _stopPreview();
    setState(() => _isUploading = true);

    try {
      final uploadService = ref.read(cloudinaryUploadServiceProvider);
      final file = File(_recordedFilePath!);
      final uploadResult = await uploadService.uploadAudio(file);

      await uploadResult.when(
        success: (audioUrl) async {
          final dataSource = ref.read(radioRemoteDataSourceProvider);
          final sendResult = await dataSource.sendVoice(
            audioUrl: audioUrl,
            duration: _recordDuration,
            takenAt: DateTime.now(),
            text: _textController.text.trim(),
            mood: _selectedMood,
          );

          sendResult.when(
            success: (response) {
              ref.read(radioNotifierProvider.notifier).refresh();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Đã gửi voice! +${response.expAdded} EXP'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            error: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.message),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
        error: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message), backgroundColor: Colors.red),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _reset() async {
    await _stopPreview();
    if (_recordedFilePath != null) {
      final file = File(_recordedFilePath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    setState(() {
      _recordedFilePath = null;
      _recordDuration = 0;
    });
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2D1B4E).withOpacity(0.98),
            const Color(0xFF1A1A2E).withOpacity(0.98),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Voice Message',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gửi lời yêu thương đến người thương',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isRecording
                              ? [
                                  const Color(0xFFFF6B9D),
                                  const Color(0xFFFF8E53),
                                ]
                              : _recordedFilePath != null
                              ? [
                                  const Color(0xFF4ECDC4),
                                  const Color(0xFF44A08D),
                                ]
                              : [
                                  AppColors.primaryPink.withOpacity(0.8),
                                  AppColors.primaryPink,
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isRecording
                                        ? const Color(0xFFFF6B9D)
                                        : AppColors.primaryPink)
                                    .withOpacity(0.4),
                            blurRadius: _isRecording ? 30 : 20,
                            spreadRadius: _isRecording ? 5 : 2,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isUploading
                              ? null
                              : (_isRecording
                                    ? _stopRecording
                                    : (_recordedFilePath != null
                                          ? _togglePreview
                                          : _startRecording)),
                          customBorder: const CircleBorder(),
                          child: Center(
                            child: Icon(
                              _isRecording
                                  ? Icons.stop_rounded
                                  : (_recordedFilePath != null
                                        ? (_isPreviewPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded)
                                        : Icons.mic_rounded),
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              if (_isRecording || _recordedFilePath != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isRecording)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (_isRecording) const SizedBox(width: 10),
                      Text(
                        _formatDuration(_recordDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_recordedFilePath != null && !_isRecording) ...[
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn đi kèm...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                      ),
                      prefixIcon: Icon(
                        Icons.message_rounded,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      counterStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chọn mood',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _moods.length,
                    itemBuilder: (context, index) {
                      final mood = _moods[index];
                      final isSelected = _selectedMood == mood['value'];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 8,
                          right: index == _moods.length - 1 ? 0 : 8,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(
                              () => _selectedMood = mood['value'] as String,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (mood['color'] as Color).withOpacity(0.3)
                                  : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? mood['color'] as Color
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  mood['emoji'] as String,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  mood['label'] as String,
                                  style: TextStyle(
                                    color: isSelected
                                        ? mood['color'] as Color
                                        : Colors.white.withOpacity(0.7),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUploading ? null : _reset,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Ghi lại'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadAndSend,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(_isUploading ? 'Đang gửi...' : 'Gửi voice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (!_isRecording && _recordedFilePath == null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Nhấn để bắt đầu ghi âm',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
