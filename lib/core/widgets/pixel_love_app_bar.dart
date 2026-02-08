import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/widgets/app_back_icon.dart';
import 'package:pixel_love/routes/app_routes.dart';

class PixelLoveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Color backgroundColor;
  final bool centerTitle;
  final double height;
  final VoidCallback? onBackPressed;
  final Widget? flexibleSpace;
  final EdgeInsetsGeometry? leadingPadding;
  final double? leadingWidth;

  const PixelLoveAppBar({
    super.key,
    this.title,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.centerTitle = true,
    this.height = 66,
    this.onBackPressed,
    this.flexibleSpace,
    this.leadingPadding,
    this.leadingWidth,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      flexibleSpace: flexibleSpace,
      elevation: 0,
      toolbarHeight: height,
      leadingWidth: leadingWidth ?? height, // Square leading area by default
      centerTitle: centerTitle,
      title: title,
      leading: Padding(
        padding: leadingPadding ?? EdgeInsets.zero,
        child: GestureDetector(
          onTap:
              onBackPressed ??
              () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
          child: const Center(child: AppBackIcon()),
        ),
      ),
      actions: actions,
    );
  }
}
