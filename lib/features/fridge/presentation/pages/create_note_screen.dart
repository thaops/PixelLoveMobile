import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/fridge/presentation/controllers/create_note_controller.dart';
import 'package:pixel_love/features/fridge/presentation/widgets/note_back_button.dart';
import 'package:pixel_love/features/fridge/presentation/widgets/note_background.dart';
import 'package:pixel_love/features/fridge/presentation/widgets/note_save_button.dart';
import 'package:pixel_love/features/fridge/presentation/widgets/note_text_input.dart';
import 'package:pixel_love/features/fridge/providers/fridge_providers.dart';

class CreateNoteScreen extends ConsumerStatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  ConsumerState<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  final _imageKey = GlobalKey();
  Size? _imageSize;
  late CreateNoteController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CreateNoteController(
      ref: ref,
      context: context,
      contentController: _contentController,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.loadRewardedAd();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createNoteNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: LoveBackground(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: Stack(
              children: [
                const NoteBackButton(),
                NoteBackground(
                  imageKey: _imageKey,
                  onImageLoaded: () =>
                      _controller.measureImage(_imageKey, (size) {
                        if (_imageSize != size) {
                          setState(() => _imageSize = size);
                        }
                      }),
                ),
                NoteTextInput(
                  controller: _contentController,
                  focusNode: _focusNode,
                  imageSize: _imageSize,
                  onChanged: _controller.handleTextChanged,
                ),
                NoteSaveButton(
                  isLoading: state.isLoading,
                  onTap: _controller.handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
