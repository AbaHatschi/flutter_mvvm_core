import 'package:flutter/material.dart';

/// Reusable AppBar widget with NavigationService for consistent back behavior
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.showBackButton = true,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: showBackButton
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
