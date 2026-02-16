import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/tarot/data/models/tarot_response.dart';
import 'package:pixel_love/features/tarot/providers/tarot_providers.dart';

class TarotScreen extends ConsumerStatefulWidget {
  const TarotScreen({super.key});

  @override
  ConsumerState<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends ConsumerState<TarotScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tarotNotifierProvider.notifier).syncStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(tarotNotifierProvider.notifier).syncStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tarotNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarot Sync'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade900, Colors.black],
          ),
        ),
        child: SafeArea(child: _buildContent(state)),
      ),
    );
  }

  Widget _buildContent(state) {
    if (state.isLoading && state.status == TarotStatus.IDLE) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    switch (state.status) {
      case TarotStatus.IDLE:
        return _buildIdleState();
      case TarotStatus.WAITING:
        return _buildWaitingState(state);
      case TarotStatus.READY:
        return _buildReadyState(state);
      case TarotStatus.REVEALED:
        return _buildRevealedState(state);
      default:
        return const SizedBox();
    }
  }

  Widget _buildIdleState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Chọn một lá cho hôm nay',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => _buildTarotCard(index + 1, false),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingState(state) {
    final mySelected = state.myCard != null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          mySelected
              ? 'Đợi người ấy...'
              : 'Người ấy đã chọn\nBạn hãy chọn để mở cùng nhau',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTarotCard(state.myCard ?? 0, true, glow: mySelected),
            const SizedBox(width: 20),
            _buildTarotCard(0, false, glow: state.partnerSelected),
          ],
        ),
        if (!mySelected) ...[
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => _buildTarotCard(index + 1, false),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReadyState(state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${state.countdown}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 120,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Chuẩn bị reveal!',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealedState(state) {
    final result = state.result;
    if (result == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTarotCard(result.cardA, true),
              const SizedBox(width: 20),
              _buildTarotCard(result.cardB, true),
            ],
          ),
          const SizedBox(height: 32),
          if (result.streak != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥 ', style: TextStyle(fontSize: 20)),
                  Text(
                    'Streak giữ vững: ${result.streak} ngày',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            result.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                const Text(
                  'Câu hỏi dành cho hai bạn:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  result.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              // Action to message partner
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text('Nhắn cho người ấy'),
          ),
        ],
      ),
    );
  }

  Widget _buildTarotCard(int id, bool isRevealed, {bool glow = false}) {
    final state = ref.watch(tarotNotifierProvider);

    return GestureDetector(
      onTap: () {
        if (state.isLoading ||
            state.myCard != null ||
            state.status == TarotStatus.REVEALED) {
          return;
        }
        if (!isRevealed && id != 0) {
          ref.read(tarotNotifierProvider.notifier).selectCard(id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 80,
        height: 120,
        decoration: BoxDecoration(
          color: isRevealed ? Colors.white : Colors.indigo.shade800,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: glow ? Colors.yellow : Colors.white24,
            width: glow ? 3 : 1,
          ),
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isRevealed
              ? Text(
                  '$id',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Icon(Icons.star, color: Colors.white54, size: 32),
        ),
      ),
    );
  }
}
