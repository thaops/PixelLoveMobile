import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/auth/providers/auth_providers.dart';
import 'package:pixel_love/features/tarot/data/models/tarot_response.dart';
import 'package:pixel_love/features/tarot/providers/tarot_providers.dart';
import 'package:pixel_love/features/tarot/presentation/widgets/tarot_card_widget.dart';
import 'package:pixel_love/features/tarot/presentation/widgets/tarot_background_effects.dart';
import 'package:pixel_love/features/tarot/presentation/widgets/tarot_connection_widget.dart';

class TarotScreen extends ConsumerStatefulWidget {
  const TarotScreen({super.key});

  @override
  ConsumerState<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends ConsumerState<TarotScreen>
    with WidgetsBindingObserver {
  int? _localSelectedId;

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

  Future<void> _handleCardSelection(int id) async {
    if (_localSelectedId != null) return;
    HapticFeedback.mediumImpact();
    setState(() => _localSelectedId = id);
    await Future.delayed(const Duration(milliseconds: 400));
    ref.read(tarotNotifierProvider.notifier).selectCard(id);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tarotNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tarot Ritual',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Color(0xFF2B2D42),
            shadows: [Shadow(color: Colors.white70, blurRadius: 10)],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2B2D42)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroud_tarot.png',
              fit: BoxFit.cover,
            ),
          ),
          const Positioned.fill(child: TarotBackgroundShimmer()),
          const Positioned.fill(child: TarotParticles()),
          if (state.status == TarotStatus.READY)
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: _buildContent(state, authState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state, authState) {
    if (state.isLoading && state.status == TarotStatus.IDLE) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6FAE),
          strokeWidth: 2,
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: _buildStateUI(state, authState),
    );
  }

  Widget _buildStateUI(state, authState) {
    switch (state.status) {
      case TarotStatus.IDLE:
        return _buildIdleState(state);
      case TarotStatus.WAITING:
        return _buildWaitingState(state, authState);
      case TarotStatus.READY:
        return _buildReadyState(state);
      case TarotStatus.REVEALED:
        return _buildRevealedState(state);
      default:
        return const SizedBox();
    }
  }

  Widget _buildIdleState(state) {
    return Column(
      key: const ValueKey('idle'),
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Chạm vào một lá bài',
          style: TextStyle(
            color: Color(0xFF5C5470),
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            shadows: [Shadow(color: Colors.white, blurRadius: 12)],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Lắng nghe trái tim bạn',
          style: TextStyle(
            color: Color(0xFF5C5470),
            fontSize: 15,
            letterSpacing: 0.5,
            // opacity: 0.8, // TextStyle does not have an opacity property
          ),
        ),
        const SizedBox(height: 80),
        SizedBox(
          height: 260,
          width: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                top: 30,
                child: Transform.rotate(
                  angle: -0.2,
                  child: TarotCardWidget(
                    id: 1,
                    isSelected: _localSelectedId == 1,
                    onTap: () => _handleCardSelection(1),
                  ),
                ),
              ),
              Positioned(
                left: 90,
                top: 0,
                child: TarotCardWidget(
                  id: 2,
                  isSelected: _localSelectedId == 2,
                  onTap: () => _handleCardSelection(2),
                ),
              ),
              Positioned(
                right: 0,
                top: 30,
                child: Transform.rotate(
                  angle: 0.2,
                  child: TarotCardWidget(
                    id: 3,
                    isSelected: _localSelectedId == 3,
                    onTap: () => _handleCardSelection(3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingState(state, authState) {
    final mySelected = state.myCard != null;
    final user = authState.currentUser;

    return Column(
      key: const ValueKey('waiting'),
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        TarotConnectionWidget(
          myAvatar: user?.avatar,
          partnerAvatar: null, // Placeholder or fetch from couple state
          isReady: mySelected && state.partnerSelected,
        ),
        const SizedBox(height: 48),
        if (mySelected) ...[
          const Text(
            'Bạn đã rút bài',
            style: TextStyle(
              color: Color(0xFF5C5470),
              fontSize: 16,
              letterSpacing: 0.5,
              shadows: [Shadow(color: Colors.white, blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Đợi người ấy...',
            style: TextStyle(
              color: Color(0xFF2B2D42),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              shadows: [Shadow(color: Colors.white, blurRadius: 10)],
            ),
          ),
        ] else ...[
          const Text(
            'Người ấy đã chờ bạn',
            style: TextStyle(
              color: Color(0xFFFF6FAE),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              shadows: [Shadow(color: Colors.white, blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hãy chọn một lá bài',
            style: TextStyle(
              color: Color(0xFF2B2D42),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              shadows: [Shadow(color: Colors.white, blurRadius: 10)],
            ),
          ),
        ],
        const SizedBox(height: 64),
        if (mySelected)
          Center(
            child: TarotCardWidget(
              id: state.myCard ?? 0,
              isGlow: true,
              scale: 1.2,
            ),
          )
        else
          SizedBox(
            height: 260,
            width: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  top: 30,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: TarotCardWidget(
                      id: 1,
                      isSelected: _localSelectedId == 1,
                      onTap: () => _handleCardSelection(1),
                    ),
                  ),
                ),
                Positioned(
                  left: 90,
                  top: 0,
                  child: TarotCardWidget(
                    id: 2,
                    isSelected: _localSelectedId == 2,
                    onTap: () => _handleCardSelection(2),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 30,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: TarotCardWidget(
                      id: 3,
                      isSelected: _localSelectedId == 3,
                      onTap: () => _handleCardSelection(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReadyState(state) {
    return Center(
      key: const ValueKey('ready'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Đã sẵn sàng!',
            style: TextStyle(
              color: Color(0xFF2B2D42),
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              shadows: [Shadow(color: Colors.white, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 48),
          TarotRevealButton(
            onPressed: () {
              ref.read(tarotNotifierProvider.notifier).revealTarot();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRevealedState(state) {
    final result = state.result;
    if (result == null) return const SizedBox();

    return Stack(
      key: const ValueKey('revealed'),
      children: [
        const Positioned.fill(child: TarotBackgroundShimmer()),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TarotCardWidget(
                    id: result.cardA,
                    isRevealed: true,
                    scale: 0.9,
                  ),
                  const SizedBox(width: 20),
                  TarotCardWidget(
                    id: result.cardB,
                    isRevealed: true,
                    scale: 0.9,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              if (result.streak != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6FAE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF6FAE).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'Kết nối thứ ${result.streak} liên tiếp',
                        style: const TextStyle(
                          color: Color(0xFFFF6FAE),
                          fontWeight: FontWeight.w600,
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
                  color: Color(0xFF5C5470),
                  fontSize: 17,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(color: Colors.white54, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Color(0xFFFF6FAE),
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Hỏi người ấy:',
                      style: TextStyle(
                        color: Color(0xFF5C5470),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFF6FAE),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Colors.white, blurRadius: 8)],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6FAE),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFFFF6FAE).withOpacity(0.4),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Lưu giữ kỷ niệm này',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class TarotRevealButton extends StatefulWidget {
  final VoidCallback onPressed;
  const TarotRevealButton({super.key, required this.onPressed});

  @override
  State<TarotRevealButton> createState() => _TarotRevealButtonState();
}

class _TarotRevealButtonState extends State<TarotRevealButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFF6FAE,
                ).withOpacity(0.3 + 0.4 * _controller.value),
                blurRadius: 15 + 10 * _controller.value,
                spreadRadius: 2 + 3 * _controller.value,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6FAE),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Lật kết quả của chúng ta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
