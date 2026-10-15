import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// لوگوی رسمی مافیا رادیکال؛ فایل اصلی کلاه و ستاره از assets/icon می‌آید.
class LegacyRadicalLogoMark extends StatelessWidget {
  final double size;

  const LegacyRadicalLogoMark({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/icon/app_icon_foreground.svg',
        width: size,
        height: size,
        fit: BoxFit.contain,
        semanticsLabel: 'لوگوی مافیا رادیکال، کلاه با ستاره',
      ),
    );
  }
}

class RadicalLogoMark extends StatelessWidget {
  const RadicalLogoMark({super.key, this.size = 120});
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/logo/mafia_radical_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
}
