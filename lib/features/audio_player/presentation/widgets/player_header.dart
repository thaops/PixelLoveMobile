import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/features/audio_player/providers/audio_providers.dart';

class PlayerHeader extends ConsumerStatefulWidget {
  const PlayerHeader({super.key});

  @override
  ConsumerState<PlayerHeader> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends ConsumerState<PlayerHeader> {
  Timer? _timer;
  String? _remainingTime;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final timerEndsAt = ref.read(audioPlayerNotifierProvider).timerEndsAt;
      if (timerEndsAt == null) {
        if (_remainingTime != null) {
          setState(() {
            _remainingTime = null;
          });
        }
        return;
      }

      final endTime = DateTime.parse(timerEndsAt).toLocal();
      final now = DateTime.now();
      final difference = endTime.difference(now);

      if (difference.isNegative) {
        if (_remainingTime != null) {
          setState(() {
            _remainingTime = null;
          });
        }
      } else {
        final minutes = difference.inMinutes;
        final seconds = difference.inSeconds % 60;
        final formatted =
            '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
        if (_remainingTime != formatted) {
          setState(() {
            _remainingTime = formatted;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(audioPlayerNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () => context.pop(),
          ),
          Column(
            children: [
              Text(
                'PLAYING FROM PLAYLIST',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '🎧 Đang nghe cùng ${state.partnerName ?? 'Minh'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_remainingTime != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.pinkAccent.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.pinkAccent,
                        size: 10,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _remainingTime!,
                        style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
