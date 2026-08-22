import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.celebration, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
