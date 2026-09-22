import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MafiaRadicalWordmark extends StatelessWidget {
  final double width;
  final double? height;

  const MafiaRadicalWordmark({
    super.key,
    this.width = 320,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedHeight = height ?? width * .1875;
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: resolvedHeight,
        child: SvgPicture.asset(
          'assets/images/mafia_radical_wordmark.svg',
          fit: BoxFit.contain,
          semanticsLabel: 'MAFIA-RADICAL',
        ),
      ),
    );
  }
}
