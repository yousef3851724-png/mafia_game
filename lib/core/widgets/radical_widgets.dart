import 'package:flutter/material.dart';

import '../theme/radical_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool accent;
  final double radius;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.accent = false, this.radius = 22});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: RadicalTheme.glass(accent: accent, radius: radius),
        child: child,
      );
}

class RadicalButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  const RadicalButton({super.key, required this.onPressed, required this.child, this.icon});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.arrow_forward_rounded, color: RadicalTheme.ink),
          label: child,
        ),
      );
}

class RadicalIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  const RadicalIcon(this.icon, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) => Icon(icon, size: size, color: color ?? RadicalTheme.goldBright);
}
