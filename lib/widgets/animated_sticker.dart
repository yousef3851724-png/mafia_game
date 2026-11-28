import 'dart:math' as math;
import 'package:flutter/material.dart';

enum StickerEffect { bounce, wiggle, pulse, float, swing }

class AnimatedSticker extends StatefulWidget {
  final String asset;
  final double size;
  final StickerEffect? effect;
  final bool animate;

  const AnimatedSticker({
    super.key,
    required this.asset,
    this.size = 80,
    this.effect,
    this.animate = true,
  });

  @override
  State<AnimatedSticker> createState() => _AnimatedStickerState();
}

class _AnimatedStickerState extends State<AnimatedSticker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final StickerEffect _effect;

  @override
  void initState() {
    super.initState();
    final h = widget.asset.codeUnits.fold<int>(0, (a, b) => a + b);
    _effect = widget.effect ?? StickerEffect.values[h % StickerEffect.values.length];
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200 + (h % 5) * 150),
    );
    if (widget.animate) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedSticker old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.animate && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      widget.asset,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
    final _a = widget.asset.toLowerCase();
    if (_a.endsWith('.gif') || _a.endsWith('.webp')) {
      return RepaintBoundary(child: img);
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        child: img,
        builder: (context, child) {
          final s = math.sin(_c.value * 2 * math.pi);
          final sz = widget.size;
          switch (_effect) {
            case StickerEffect.bounce:
              return Transform.translate(
                offset: Offset(0, -s.abs() * sz * 0.12),
                child: Transform.scale(
                    scaleY: 1 - (1 - s.abs()) * 0.05, child: child),
              );
            case StickerEffect.wiggle:
              return Transform.rotate(angle: s * 0.12, child: child);
            case StickerEffect.pulse:
              return Transform.scale(scale: 1 + 0.08 * s, child: child);
            case StickerEffect.float:
              return Transform.translate(
                  offset: Offset(0, s * sz * 0.06), child: child);
            case StickerEffect.swing:
              return Transform.rotate(
                  angle: s * 0.2,
                  alignment: Alignment.bottomCenter,
                  child: child);
          }
        },
      ),
    );
  }
}
