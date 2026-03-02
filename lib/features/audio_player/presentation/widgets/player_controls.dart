import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final String? timerEndsAt;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onTimerTap;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onTimerTap,
    this.timerEndsAt,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.white38, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.skip_previous_rounded,
              color: Colors.white,
              size: 44,
            ),
            onPressed: onPrevious,
          ),
          // Play/Pause Button
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFE2C55), // Vibrant Pink
                    Color(0xFF6B4EE6), // Vibrant Purple
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFE2C55).withOpacity(0.35),
                    blurRadius: 25,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.skip_next_rounded,
              color: Colors.white,
              size: 44,
            ),
            onPressed: onNext,
          ),
          IconButton(
            icon: Icon(
              timerEndsAt != null ? Icons.timer : Icons.timer_outlined,
              color: timerEndsAt != null ? Colors.pinkAccent : Colors.white38,
              size: 26,
            ),
            onPressed: onTimerTap,
          ),
        ],
      ),
    );
  }
}
