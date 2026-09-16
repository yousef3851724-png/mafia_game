import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum FrameType { none, gold, fire, lightning, neon }

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
        return const Color(0xFFFF4500);
      case FrameType.lightning:
        return const Color(0xFF00E5FF);
      case FrameType.gold:
        return const Color(0xFFFFD700);
      case FrameType.neon:
        return const Color(0xFF39FF14);
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasFrame && isAlive)
            Container(
              width: size + 10,
              height: size + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: frameColor.withOpacity(.6), blurRadius: 12, spreadRadius: 2),
                ],
              ),
            ),
          if (hasFrame)
            Container(
              width: size + 8,
              height: size + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isAlive ? frameColor : Colors.grey.shade700, width: 3.5),
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAlive ? const Color(0xFF2A2A2A) : Colors.black87,
            ),
            child: ClipOval(child: _buildImage()),
          ),
          if (!isAlive)
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
              child: const Icon(Icons.close, color: Colors.redAccent, size: 40),
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
      style: TextStyle(fontSize: size * .4, fontWeight: FontWeight.bold, color: isAlive ? Colors.white : Colors.grey),
    ),
  );
}
