import 'package:flutter/material.dart';

import '../theme/radical_theme.dart';

/// Shared page shell: Radical gradient background, safe insets and consistent padding.
class RadicalScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final EdgeInsetsGeometry padding;
  final bool safeArea;

  const RadicalScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Scaffold(
      backgroundColor: RadicalTheme.ink,
      appBar: appBar,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [RadicalTheme.panel2, RadicalTheme.ink, RadicalTheme.ink],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: safeArea ? SafeArea(child: content) : content,
      ),
    );
  }
}
