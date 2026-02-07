import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/widgets/background_loading_screen.dart';
import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';
import 'package:pixel_love/features/fridge/presentation/controllers/fridge_controller.dart';
import 'package:pixel_love/features/fridge/presentation/widgets/fridge_background_image.dart';
import 'package:pixel_love/features/fridge/presentation/widgets/fridge_create_note_button.dart';
import 'package:pixel_love/features/fridge/presentation/widgets/fridge_note_item.dart';
import 'package:pixel_love/features/fridge/presentation/widgets/fridge_note_preview_dialog.dart';
import 'package:pixel_love/features/fridge/providers/fridge_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';

class FridgeScreen extends ConsumerStatefulWidget {
  const FridgeScreen({super.key});

  @override
  ConsumerState<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends ConsumerState<FridgeScreen> {
  late FridgeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FridgeController(
      ref: ref,
      context: context,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fridgeState = ref.watch(fridgeNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _buildAppBar(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: _buildBody(fridgeState),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.home);
          }
        },
      ),
    );
  }

  Widget _buildBody(fridgeState) {
    final fridgeData = fridgeState.fridgeData;
    final backgroundUrl = fridgeData?.background.imageUrl ?? '';

    _controller.shouldResetPreload(backgroundUrl);

    if (fridgeData == null || !_controller.backgroundLoaded) {
      _schedulePreload(fridgeData);
      return BackgroundLoadingScreen(
        backgroundImageUrl: backgroundUrl,
        title: 'Đang tải tủ lạnh kỷ niệm',
        subtitle: 'Vui lòng đợi...',
        onLoadComplete: () {},
        onLoadError: _controller.onLoadError,
      );
    }

    return Stack(
      children: [
        FridgeBackgroundImage(background: fridgeData.background),
        ..._buildNotes(fridgeData.notes),
        const FridgeCreateNoteButton(),
      ],
    );
  }

  void _schedulePreload(Fridge? fridgeData) {
    if (fridgeData == null || _controller.isPreloading) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.preloadAssets(fridgeData);
    });
  }

  List<Widget> _buildNotes(List<FridgeNote> notes) {
    final screenSize = MediaQuery.of(context).size;
    final sortedNotes = List<FridgeNote>.from(notes)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return sortedNotes.map((note) {
      final left = screenSize.width * note.position.x;
      final top = screenSize.height * note.position.y;
      const noteWidth = 110.0;

      return Positioned(
        left: left - (noteWidth / 2),
        top: top,
        child: GestureDetector(
          onTap: () => FridgeNotePreviewDialog.show(context, note),
          child: Transform.rotate(
            angle: note.rotation,
            child: FridgeNoteItem(note: note, width: noteWidth),
          ),
        ),
      );
    }).toList();
  }
}
