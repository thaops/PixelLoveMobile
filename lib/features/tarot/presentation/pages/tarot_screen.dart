import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int? _localSelectedId;
  int _revealedStep = 0; // 0: Energy, 1: Message, 2: Advice
  late AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    Future.microtask(() {
      ref.read(tarotNotifierProvider.notifier).syncStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleController.dispose();
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

  void _nextStep() {
    if (_revealedStep < 2) {
      setState(() => _revealedStep++);
      HapticFeedback.selectionClick();
    } else {
      setState(() {
        _revealedStep = 0;
        _localSelectedId = null;
      });
    }
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
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const AppBackIcon(size: 48),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              setState(() => _revealedStep = 0);
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
    if (state.isLoading &&
        state.status == TarotStatus.IDLE &&
        _localSelectedId == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6FAE),
          strokeWidth: 2,
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeInOutQuart,
      switchOutCurve: Curves.easeInOutQuart,
      child: _buildStateUI(state, authState),
    );
  }

  Widget _buildStateUI(state, authState) {
    if (state.status == TarotStatus.REVEALED) {
      return _buildRevealedState(state, authState);
    }

    if (state.status == TarotStatus.WAITING ||
        state.status == TarotStatus.READY ||
        _localSelectedId != null) {
      return _buildWaitingState(
        state,
        authState,
        isDecoding: state.status == TarotStatus.READY,
      );
    }

    return _buildIdleState(state, authState);
  }

  Widget _buildIdleState(state, authState) {
    final user = authState.currentUser;

    return Container(
      key: const ValueKey('idle'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.06),
          TarotConnectionWidget(
            myAvatar: user?.avatar,
            partnerAvatar: null,
            isReady: state.partnerSelected,
          ),
          const SizedBox(height: 24),
          Text(
            "Hãy chọn một lá bài, xem bạn và đối phương ngày hôm nãy đang như nào nhé",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 44),
          Hero(tag: 'selection_grid', child: _buildSelectionGrid()),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.06),
          TarotConnectionWidget(
            myAvatar: user?.avatar,
            partnerAvatar: null,
            isReady: (mySelected && state.partnerSelected) || isDecoding,
          ),
          const SizedBox(height: 48),
          Text(
            isDecoding
                ? 'Đang giải mã huyễn mộng...'
                : (mySelected ? 'Kết nối đã sẵn sàng' : 'Waiting...'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 60),
          if (mySelected)
            Center(
              child: TarotCardWidget(
                id: state.myCard ?? 0,
                isGlow: true,
                scale: isDecoding ? 1.2 : 1.1,
              ),
            )
          else
            _buildSelectionGrid(),
        ],
      ),
    );
  }

  Widget _buildRevealedState(state, authState) {
    final result = state.result!;
    final user = authState.currentUser;
    String label = '';
    String content = '';
    Color themeColor = const Color(0xFFFF5794);

    if (_revealedStep == 0) {
      label = 'NĂNG LƯỢNG';
      content = result.energy;
    } else if (_revealedStep == 1) {
      label = 'THÔNG ĐIỆP';
      content = result.message;
    } else {
      label = 'LỜI KHUYÊN';
      content = result.advice;
    }

    return GestureDetector(
      onTap: _nextStep,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.001),
              TarotConnectionWidget(
                myAvatar: user?.avatar,
                partnerAvatar: null,
                isReady: true,
              ),
              const SizedBox(height: 0),
              AnimatedBuilder(
                animation: _idleController,
                builder: (context, switcherChild) {
                  return Transform.translate(
                    offset: Offset(0, -16 + (12 * _idleController.value)),
                    child: Transform.rotate(
                      angle: 0.015 * (_idleController.value - 0.5),
                      child: switcherChild,
                    ),
                  );
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  layoutBuilder:
                      (Widget? currentChild, List<Widget> previousChildren) {
                        return Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        final isIncoming = child.key == ValueKey(_revealedStep);
                        final flipAnimation =
                            Tween<double>(begin: 1.5, end: 0.0).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOutQuart,
                              ),
                            );

                        return AnimatedBuilder(
                          animation: flipAnimation,
                          child: child,
                          builder: (context, child) {
                            final value = isIncoming
                                ? flipAnimation.value
                                : -flipAnimation.value;
                            final rotation = value.clamp(-1.5, 1.5);
                            final scale =
                                1.0 -
                                (animation.value < 0.5
                                    ? (1.0 - animation.value) * 0.08
                                    : (animation.value) * 0.08);

                            return Opacity(
                              opacity: animation.value,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(rotation)
                                  ..scale(scale),
                                alignment: Alignment.center,
                                child: child,
                              ),
                            );
                          },
                        );
                      },
                  child: Center(
                    key: ValueKey(_revealedStep),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.82,
                      height: MediaQuery.of(context).size.height * 0.72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/img_tarot.png'),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom:
                                  MediaQuery.of(context).size.height *
                                      0.72 *
                                      0.65 +
                                  16,
                              left: 40,
                              right: 40,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: themeColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                      shadows: [
                                        Shadow(
                                          color: themeColor.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.72 *
                                  0.65,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.75),
                                      border: Border(
                                        top: BorderSide(
                                          color: themeColor.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Text(
                                          content,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: themeColor,
                                            fontSize: _revealedStep == 0
                                                ? 21
                                                : 16.5,
                                            fontWeight: _revealedStep == 0
                                                ? FontWeight.w900
                                                : FontWeight.w600,
                                            height: 1.6,
                                            letterSpacing: 0.2,
                                            shadows: [
                                              Shadow(
                                                color: Colors.white,
                                                blurRadius: 10,
                                              ),
                                              Shadow(
                                                color: themeColor.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _revealedStep == index ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _revealedStep == index
                        ? themeColor
                        : themeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
