import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/custom_loading_widget.dart';
import 'package:pixel_love/features/startup/notifiers/startup_notifier.dart';

class SplashContent extends StatelessWidget {
  final AsyncValue<StartupState> startupState;

  const SplashContent({super.key, required this.startupState});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          startupState.when(
            data: (state) {
              if (state.isLoading) {
                return const CustomLoadingWidget(size: 120);
              } else if (state.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: AppColors.errorText),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
            loading: () => const CustomLoadingWidget(),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                error.toString(),
                style: TextStyle(color: AppColors.errorText),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
