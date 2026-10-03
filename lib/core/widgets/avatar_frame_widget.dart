import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/radical_theme.dart';

enum FrameType {
  none,
  gold,
  fire,
  lightning,
  neon,
  eagle,
  pinkRose,
  purpleOrchid,
  prismaticCrown,
  premiumPinkPurple,
}

extension FrameTypeSvg on FrameType {
  String? get svgAsset {
    switch (this) {
      case FrameType.eagle:
        return 'assets/frames/mafia_radical_eagle.svg';
      case FrameType.pinkRose:
        return 'assets/frames/mafia_radical_pink_rose.svg';
      case FrameType.purpleOrchid:
        return 'assets/frames/mafia_radical_purple_orchid.svg';
      case FrameType.prismaticCrown:
        return 'assets/frames/mafia_radical_prismatic_crown.svg';
      case FrameType.premiumPinkPurple:
        return 'assets/frames/mafia_radical_premium_pink_purple.svg';
      default:
        return null;
    }
  }
}

class AvatarFrameWidget extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackAsset;
  final String fallbackInitial;
  final FrameType frameType;
  final double size;
  final bool isAlive;

  const AvatarFrameWidget({
    super.key,
    this.imageUrl,
    this.fallbackAsset,
    this.fallbackInitial = '?',
    this.frameType = FrameType.none,
    this.size = 70.0,
    this.isAlive = true,
  });

  Color _getFrameColor() {
    switch (frameType) {
      case FrameType.fire:
        return RadicalTheme.violetBright;
      case FrameType.lightning:
        return RadicalTheme.goldBright;
      case FrameType.gold:
        return RadicalTheme.goldBright;
      case FrameType.neon:
        return RadicalTheme.violet;
      case FrameType.eagle:
        return RadicalTheme.goldBright;
      case FrameType.pinkRose:
        return const Color(0xFFFF7EB6);
      case FrameType.purpleOrchid:
        return RadicalTheme.violetSoft;
      case FrameType.prismaticCrown:
        return RadicalTheme.cyan;
      case FrameType.premiumPinkPurple:
        return RadicalTheme.violetBright;
      case FrameType.none:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final frameColor = _getFrameColor();
    final hasFrame = frameType != FrameType.none;
    return SizedBox(
      width: size + 16,
      height: size + 16,
      child: Stack(clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (hasFrame && frameType.svgAsset != null)
            IgnorePointer(
              child: Opacity(
                opacity: isAlive ? 1.0 : 0.35,
                child: SvgPicture.asset(
                  frameType.svgAsset!,
                  width: size * 1.4,
                  height: size * 1.4,
                ),
              ),
            ),
          if (hasFrame && isAlive)
            Container(
              width: size + 10,
              height: size + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: RadicalTheme.goldGlow(blur: 12, opacity: .10).map((shadow) => shadow.copyWith(color: frameColor.withValues(alpha: shadow.color.a * 0.7))).toList(),
              ),
            ),
          if (hasFrame && frameType.svgAsset == null)
            Container(
              width: size + 8,
              height: size + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isAlive ? frameColor : RadicalTheme.panel3, width: 3.5),
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAlive ? RadicalTheme.panel3 : RadicalTheme.ink,
            ),
            child: ClipOval(child: _buildImage()),
          ),
          if (!isAlive)
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xB806070B)),
              child: const Icon(Icons.close, color: RadicalTheme.violetBright, size: 40),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (fallbackAsset != null && fallbackAsset!.isNotEmpty) {
      final path = fallbackAsset!.toLowerCase();
      if (path.endsWith('.svg')) {
        return SvgPicture.asset(
          fallbackAsset!,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => _buildRemoteOrFallback(),
        );
      }
      return Image.asset(
        fallbackAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildRemoteOrFallback(),
      );
    }
    return _buildRemoteOrFallback();
  }

  Widget _buildRemoteOrFallback() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() => Center(
    child: Text(
      fallbackInitial.isNotEmpty ? fallbackInitial[0].toUpperCase() : '?',
      style: TextStyle(fontSize: size * .4, fontWeight: FontWeight.bold, color: isAlive ? RadicalTheme.textPrimary : RadicalTheme.smoke),
    ),
  );
}
