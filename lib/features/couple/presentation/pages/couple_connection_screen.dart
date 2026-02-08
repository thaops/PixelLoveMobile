import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/couple/presentation/notifiers/couple_connection_notifier.dart';
import 'package:pixel_love/features/couple/presentation/widgets/couple_connection_app_bar.dart';
import 'package:pixel_love/features/couple/presentation/widgets/couple_connection_footer.dart';
import 'package:pixel_love/features/couple/presentation/widgets/couple_connection_header.dart';
import 'package:pixel_love/features/couple/presentation/widgets/input_code_section.dart';
import 'package:pixel_love/features/couple/presentation/widgets/share_code_section.dart';
import 'package:pixel_love/features/couple/providers/couple_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';

class CoupleConnectionScreen extends ConsumerWidget {
  const CoupleConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<CoupleConnectionState>(coupleConnectionNotifierProvider, (
      previous,
      next,
    ) {
      if ((previous?.isLoading == true && !next.isLoading) || next.isPaired) {
        final storageService = ref.read(storageServiceProvider);
        final user = storageService.getUser();

        if (user?.coupleRoomId != null && user!.coupleRoomId!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.home);
            }
          });
        }
      }
    });

    return Scaffold(
      body: LoveBackground(
        child: SafeArea(
          child: Column(
            children: [
              const CoupleConnectionAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 8),
                        CoupleConnectionHeader(),
                        SizedBox(height: 24),
                        ShareCodeSection(),
                        SizedBox(height: 16),
                        InputCodeSection(),
                        SizedBox(height: 16),
                        CoupleConnectionFooter(),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
