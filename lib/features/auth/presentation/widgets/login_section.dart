import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/app_loader_overlay.dart';
import 'package:pixel_love/features/auth/notifiers/auth_state.dart';
import 'package:pixel_love/features/auth/providers/auth_providers.dart';
import 'package:pixel_love/features/auth/presentation/utils/auth_navigation_helper.dart';
import 'package:pixel_love/features/auth/presentation/widgets/auth_button.dart';
import 'package:pixel_love/features/auth/presentation/widgets/auth_disclaimer.dart';
import 'package:pixel_love/features/auth/presentation/widgets/auth_error_message.dart';

class LoginSection extends ConsumerWidget {
  const LoginSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isLoading && !context.isAppLoaderVisible) {
        context.showAppLoader();
      } else if (!next.isLoading && context.isAppLoaderVisible) {
        context.hideAppLoader();
      }

      if (previous != null && previous.isLoading && !next.isLoading) {
        if (next.currentUser != null && next.errorMessage == null) {
          AuthNavigationHelper.navigateAfterLogin(context, next.currentUser!);
        }
      }
    });

    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/img-login-section.png'),
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              spacing: 16,
              children: [
                AuthButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          ref
                              .read(authNotifierProvider.notifier)
                              .loginWithGoogle();
                        },
                  imagePath: 'assets/images/img-google.png',
                  label: 'Đăng nhập với Google',
                  backgroundColor: AppColors.primaryPink,
                  textColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (authState.errorMessage != null &&
                authState.errorMessage!.isNotEmpty)
              AuthErrorMessage(message: authState.errorMessage!),
            const AuthDisclaimer(),
          ],
        ),
      ),
    );
  }
}
