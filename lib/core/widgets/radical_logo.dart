import 'package:flutter/material.dart';
import '../theme/radical_theme.dart';

class RadicalLogoMark extends StatelessWidget {
  final double size;

  const RadicalLogoMark({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadicalTheme.goldButtonGradient,
        boxShadow: RadicalTheme.goldGlow(blur: size * 0.25, opacity: 0.45),
        border: Border.all(color: RadicalTheme.ink, width: size * 0.02),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: size * 0.5,
          color: RadicalTheme.ink,
        ),
      ),
    );
  }
}
