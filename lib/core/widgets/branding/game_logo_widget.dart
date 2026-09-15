import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum MafiaLogoScenario { classic, darkCity, western, halloween, prison, cyberpunk }

/// Canonical Mafia Radical branding. The scenario argument is retained for
/// compatibility, while the master Radical wordmark stays consistent.
class MafiaRadicalLogo extends StatelessWidget {
  final double size;
  final MafiaLogoScenario scenario;

  const MafiaRadicalLogo({super.key, this.size = 110, this.scenario = MafiaLogoScenario.classic});

  @override
  Widget build(BuildContext context) {
    final width = size * 1.75;
    return Semantics(
      label: 'MAFIA-RADICAL',
      image: true,
      child: RepaintBoundary(
        child: SizedBox(
          width: width,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * .28),
              boxShadow: const [
                BoxShadow(color: Color(0x33E3B873), blurRadius: 22, spreadRadius: 1),
                BoxShadow(color: Color(0x229E263D), blurRadius: 28),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(size * .08),
              child: SvgPicture.asset(
                'assets/images/mafia_radical_wordmark.svg',
                fit: BoxFit.contain,
                semanticsLabel: 'MAFIA-RADICAL',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
