import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';

class PetPreviewCaption extends StatefulWidget {
  const PetPreviewCaption({
    super.key,
    required this.state,
    required this.notifier,
  });

  final PetCaptureState state;
  final PetCaptureNotifier notifier;

  @override
  State<PetPreviewCaption> createState() => _PetPreviewCaptionState();
}

class _PetPreviewCaptionState extends State<PetPreviewCaption> {
  final FocusNode _captionFocusNode = FocusNode();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _captionFocusNode.addListener(_onCaptionFocusChange);
  }

  @override
  void dispose() {
    _captionFocusNode.removeListener(_onCaptionFocusChange);
    _captionFocusNode.dispose();
    super.dispose();
  }

  void _onCaptionFocusChange() {
    final isFocused = _captionFocusNode.hasFocus;
    if (_isKeyboardVisible != isFocused) {
      setState(() {
        _isKeyboardVisible = isFocused;
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFrozen = widget.state.isFrozen;
    final bottomPosition = isFrozen ? 40.0 : -120.0;
    final hasText = widget.notifier.captionController.text.isNotEmpty;
    final isFocused = _captionFocusNode.hasFocus;
    final showHint = !isFocused && !hasText;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      left: 16,
      right: 16,
      bottom: bottomPosition,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        opacity: isFrozen ? 1 : 0,
        child: TextField(
          controller: widget.notifier.captionController,
          focusNode: _captionFocusNode,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
          cursorColor: AppColors.primaryPink,
          maxLines: 1,
          maxLength: 60,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            border: InputBorder.none,
            hintText: showHint ? 'Đang nghĩ gì?' : '',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(60)],
        ),
      ),
    );
  }
}
