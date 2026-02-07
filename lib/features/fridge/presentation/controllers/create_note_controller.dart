import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/providers/ads_providers.dart';
import 'package:pixel_love/features/fridge/providers/fridge_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';

class CreateNoteController {
  final WidgetRef ref;
  final BuildContext context;
  final TextEditingController contentController;
  final VoidCallback onStateChanged;

  CreateNoteController({
    required this.ref,
    required this.context,
    required this.contentController,
    required this.onStateChanged,
  });

  void loadRewardedAd() {
    ref.read(rewardedAdServiceProvider).loadAd(onAdLoaded: onStateChanged);
  }

  Future<void> handleSave() async {
    final success = await ref
        .read(createNoteNotifierProvider.notifier)
        .createNote(contentController.text);

    if (!success || !context.mounted) return;

    ref.read(fridgeNotifierProvider.notifier).refresh();

    final adService = ref.read(rewardedAdServiceProvider);

    if (adService.isAdReady) {
      adService.showAd(
        onUserEarnedReward: (amount, type) {},
        onAdDismissed: () {
          loadRewardedAd();
          _navigateBack();
        },
        onAdFailedToShow: (error) => _navigateBack(),
      );
    } else {
      _navigateBack();
    }
  }

  void _navigateBack() {
    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.fridge);
    }
  }

  void handleTextChanged() {
    onStateChanged();
    final state = ref.read(createNoteNotifierProvider);
    if (state.errorMessage != null) {
      ref.read(createNoteNotifierProvider.notifier).clearError();
    }
  }

  void measureImage(GlobalKey imageKey, Function(Size) onMeasured) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        onMeasured(renderBox.size);
      }
    });
  }
}
