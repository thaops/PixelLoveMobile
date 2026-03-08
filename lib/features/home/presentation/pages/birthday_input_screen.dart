import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/app_back_icon.dart';
import 'package:pixel_love/routes/app_routes.dart';

class BirthdayInputScreen extends StatefulWidget {
  const BirthdayInputScreen({super.key});

  @override
  State<BirthdayInputScreen> createState() => _BirthdayInputScreenState();
}

class _BirthdayInputScreenState extends State<BirthdayInputScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animationController;
  final List<OverlayEntry> _overlayEntries = [];
  final List<GlobalKey> _boxKeys = List.generate(4, (index) => GlobalKey());
  bool _hasError = false;
  int _lastTextLength = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _controller.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onTextChanged() {
    if (_hasError) {
      setState(() {
        _hasError = false;
      });
    }

    if (_controller.text.length > _lastTextLength) {
      _showHeartAnimation(_controller.text.length - 1);
    }
    _lastTextLength = _controller.text.length;

    setState(() {});

    if (_controller.text.length == 4) {
      if (_controller.text == '0905') {
        _focusNode.unfocus();
        context.pushReplacement(AppRoutes.letterViewer);
      } else {
        setState(() {
          _hasError = true;
        });
        _animationController.forward(from: 0);
      }
    }
  }

  void _showHeartAnimation(int index) {
    if (index < 0 || index >= _boxKeys.length) return;

    final RenderBox? box =
        _boxKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final size = box.size;
    final offset = box.localToGlobal(Offset.zero);

    final entry = OverlayEntry(
      builder: (context) => _HeartParticle(
        startPosition: Offset(
          offset.dx + size.width / 2,
          offset.dy + size.height / 2,
        ),
      ),
    );

    Overlay.of(context).insert(entry);
    _overlayEntries.add(entry);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (entry.mounted) {
        entry.remove();
        _overlayEntries.remove(entry);
      }
    });
  }

  @override
  void dispose() {
    for (final entry in _overlayEntries) {
      if (entry.mounted) entry.remove();
    }
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mark_email_unread_rounded,
                      size: 80,
                      color: AppColors.primaryPink,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Mật mã trái tim ❤️',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bé iu oai, nhập ngày sinh của em\nđể mở bức thư anh gửi nhée!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final xOffset =
                            sin(_animationController.value * pi * 4) * 8;
                        return Transform.translate(
                          offset: Offset(xOffset, 0),
                          child: child,
                        );
                      },
                      child: _buildInputFields(),
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hasError ? 1.0 : 0.0,
                      child: const Text(
                        'Sai mật mã rồi, thử lại nhé!',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const AppBackIcon(size: 54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: 4,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(counterText: ""),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return _buildCodeBox(index);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBox(int index) {
    bool isFocused = _focusNode.hasFocus && _controller.text.length == index;
    bool isFilled = index < _controller.text.length;
    String char = isFilled ? _controller.text[index] : '';

    return AnimatedContainer(
      key: _boxKeys[index],
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 60,
      decoration: BoxDecoration(
        color: isFilled
            ? AppColors.primaryPink.withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasError
              ? Colors.redAccent
              : isFocused
              ? AppColors.primaryPink
              : isFilled
              ? AppColors.primaryPink.withOpacity(0.5)
              : Colors.transparent,
          width: isFocused ? 2 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primaryPink.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _hasError ? Colors.redAccent : AppColors.primaryPink,
          ),
        ),
      ),
    );
  }
}

class _HeartParticle extends StatefulWidget {
  final Offset startPosition;

  const _HeartParticle({required this.startPosition});

  @override
  State<_HeartParticle> createState() => _HeartParticleState();
}

class _HeartParticleState extends State<_HeartParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late List<Offset> _offsets;
  late List<double> _scales;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );
    _scale = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    final random = Random();
    _offsets = List.generate(5, (_) {
      return Offset(
        (random.nextDouble() - 0.5) * 150,
        -random.nextDouble() * 150 - 50,
      );
    });
    _scales = List.generate(5, (_) => 0.5 + random.nextDouble());

    _controller.forward();
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
        return Stack(
          children: List.generate(_offsets.length, (index) {
            final position = Offset(
              widget.startPosition.dx + _offsets[index].dx * _controller.value,
              widget.startPosition.dy + _offsets[index].dy * _controller.value,
            );
            return Positioned(
              left: position.dx,
              top: position.dy,
              child: Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scales[index] * _scale.value,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.pinkAccent,
                    size: 24,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
