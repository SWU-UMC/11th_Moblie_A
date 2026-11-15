import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.centerTitle,
    this.actions,
    this.fallbackLocation,
  });

  final String title;
  final bool showBackButton;
  final bool? centerTitle;
  final List<Widget>? actions;
  final String? fallbackLocation;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleBack(context),
            )
          : null,
      title: Text(title),
      actions: actions,
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else if (fallbackLocation != null) {
      context.go(fallbackLocation!);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}