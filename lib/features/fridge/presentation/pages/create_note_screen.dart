import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/fridge/presentation/notifiers/create_note_notifier.dart';
import 'package:pixel_love/features/fridge/providers/fridge_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';

class CreateNoteScreen extends ConsumerStatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  ConsumerState<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _measureImage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          _imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && mounted) {
        final size = renderBox.size;
        if (_imageSize != size) {
          setState(() {
            _imageSize = size;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final createNoteState = ref.watch(createNoteNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: LoveBackground(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Stack(
            children: [
              // Back button
              _buildBackButton(context),

              // Background note image
              _buildNoteBackground(screenSize),

              // Text input overlay
              _buildTextInput(screenSize, createNoteState),

              // Save button
              _buildSaveButton(createNoteState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteBackground(Size screenSize) {
    final noteWidth = screenSize.width * 0.9;

    return Center(
      child: SizedBox(
        key: _imageKey,
        width: noteWidth,
        child: Image.asset(
          'assets/images/note_pink.png',
          width: noteWidth,
          fit: BoxFit.contain,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame != null) {
              _measureImage();
            }
            return child;
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: noteWidth,
              height: noteWidth * 1.2,
              decoration: BoxDecoration(
                color: Colors.pink.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.note, color: Colors.pink, size: 64),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextInput(Size screenSize, CreateNoteState state) {
    final noteWidth = screenSize.width * 0.9;

    // Nếu chưa đo được kích thước ảnh, dùng kích thước ước tính
    final imageHeight = _imageSize?.height ?? (noteWidth * 1.2);

    return Center(
      child: SizedBox(
        width: noteWidth,
        height: imageHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: TextField(
            controller: _contentController,
            focusNode: _focusNode,
            maxLines: null,
            expands: true,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.4,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Viết ghi chú của bạn...',
              hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
            ),
            onChanged: (_) {
              // Clear error khi user nhập
              if (state.errorMessage != null) {
                ref.read(createNoteNotifierProvider.notifier).clearError();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(CreateNoteState state) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(24),
            color: Colors.transparent,
            shadowColor: Colors.black45,
            child: InkWell(
              onTap: state.isLoading
                  ? null
                  : () async {
                      final success = await ref
                          .read(createNoteNotifierProvider.notifier)
                          .createNote(_contentController.text);

                      if (success && mounted) {
                        // Refresh fridge data
                        ref.read(fridgeNotifierProvider.notifier).refresh();
                        // Navigate back
                        context.pop();
                      }
                    },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: state.isLoading
                      ? AppColors.primaryPink.withOpacity(0.6)
                      : AppColors.primaryPink,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Lưu ghi chú',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: SafeArea(
        child: Material(
          color: Colors.black.withOpacity(0.35),
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.fridge);
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
