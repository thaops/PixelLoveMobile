import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';
import 'package:pixel_love/routes/app_routes.dart';

class AuthNavigationHelper {
  static void navigateAfterLogin(BuildContext context, AuthUser user) {
    if (!user.isOnboarded) {
      context.go(AppRoutes.onboard);
      return;
    }

    final hasPartner = user.partnerId != null && user.partnerId!.isNotEmpty;
    final hasCoupleRoom =
        user.coupleRoomId != null && user.coupleRoomId!.isNotEmpty;
    if (hasCoupleRoom || hasPartner) {
      context.go(AppRoutes.home);
      return;
    }
    context.go(AppRoutes.coupleConnection);
    return;
  }
}
