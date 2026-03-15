import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/auth/providers/auth_providers.dart';
import 'package:pixel_love/core/widgets/app_back_icon.dart';
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
    Future.microtask(() {
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

  void _handleCardSelection(int id) {
    if (_localSelectedId != null) return;
    setState(() => _localSelectedId = id);
    HapticFeedback.mediumImpact();
    ref.read(tarotNotifierProvider.notifier).selectCard(id);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tarotNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const AppBackIcon(size: 48),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2B2D42)),
            onPressed: () {
              ref.read(tarotNotifierProvider.notifier).resetTarot();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroud_tarot.png',
              fit: BoxFit.cover,
            ),
          ),
          const Positioned.fill(child: TarotBackgroundEffects()),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: _buildContent(state, authState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state, authState) {
    if (state.status == TarotStatus.IDLE && _localSelectedId != null && !state.isLoading) {
      Future.microtask(() => setState(() => _localSelectedId = null));
    }

    if (state.isLoading && state.status == TarotStatus.IDLE) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6FAE),
          strokeWidth: 2,
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeOutCubic,
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
        return _buildWaitingState(state, authState, isDecoding: true);
      case TarotStatus.REVEALED:
        return _buildRevealedState(state);
      default:
        return const SizedBox();
    }
  }

  Widget _buildIdleState(state) {
    return Container(
      key: const ValueKey('idle'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Chạm vào một lá bài',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF5C5470),
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              shadows: [Shadow(color: Colors.white, blurRadius: 15)],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lắng nghe nhịp đập trái tim và chọn lá bài dành cho cả hai',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF5C5470),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 60),
          Hero(
            tag: 'selection_grid',
            child: _buildSelectionGrid(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSelectionGrid() {
    return SizedBox(
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
    );
  }

  Widget _buildWaitingState(state, authState, {bool isDecoding = false}) {
    final mySelected = state.myCard != null;
    final user = authState.currentUser;

    return Container(
      key: ValueKey(isDecoding ? 'ready' : 'waiting'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TarotConnectionWidget(
            myAvatar: user?.avatar,
            partnerAvatar: null,
            isReady: (mySelected && state.partnerSelected) || isDecoding,
          ),
          const SizedBox(height: 40),
          Text(
            isDecoding
                ? 'Năng lượng đang hội tụ...'
                : (mySelected ? 'Kết nối đã được thiết lập' : 'Người ấy đang đợi bạn'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFF6FAE),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              shadows: [Shadow(color: Colors.white, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isDecoding
                ? 'AI đang giải mã thông điệp dành cho cả hai'
                : (mySelected ? 'Đang cảm nhận năng lượng của người ấy...' : 'Hãy chọn một lá bài để bắt đầu'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5C5470),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 60),
          if (mySelected)
            Center(
              child: Hero(
                tag: 'selected_card',
                child: TarotCardWidget(
                  id: state.myCard ?? 0,
                  isGlow: true,
                  scale: isDecoding ? 1.4 : 1.3,
                ),
              ),
            )
          else
            Hero(
              tag: 'selection_grid',
              child: _buildSelectionGrid(),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildRevealedState(state) {
    final result = state.result!;

    return ListView(
      key: const ValueKey('revealed'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Hero(
            tag: 'selected_card',
            child: TarotCardWidget(
              id: result.cardId,
              isGlow: true,
              scale: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 48),
        Column(
          children: [
            if (result.streak > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6FAE), Color(0xFFB794F4)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6FAE).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Text(
                      'Chuỗi ${result.streak} ngày gắn kết',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
            _buildInfoSection(
              title: '✨ GIAO THOA NĂNG LƯỢNG',
              content: result.energy,
              isHighlight: true,
              icon: Icons.auto_awesome,
              accentColor: const Color(0xFFFF6FAE),
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
              title: '💬 THÔNG ĐIỆP TRÁI TIM',
              content: result.message,
              icon: Icons.favorite_rounded,
              accentColor: const Color(0xFFB794F4),
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
              title: '🌱 LỜI KHUYÊN GẮN KẾT',
              content: result.advice,
              icon: Icons.eco_rounded,
              accentColor: const Color(0xFF48BB78),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFFF6FAE).withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6FAE).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Câu hỏi dành cho hai bạn',
                    style: TextStyle(
                      color: Color(0xFF5C5470),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    result.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF2B2D42),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B2D42),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Lưu giữ kỷ niệm',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
    bool isHighlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: accentColor.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              color: const Color(0xFF2B2D42),
              fontSize: isHighlight ? 18 : 16,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
