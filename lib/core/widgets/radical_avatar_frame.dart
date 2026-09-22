import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/radical_avatar_catalog.dart';
import '../theme/radical_theme.dart';

/// Shared Radical avatar renderer used by home, profile, picker and gameplay.
class RadicalAvatarFrame extends StatefulWidget {
  final String avatarAssetPath;
  final RadicalFrameTier tier;
  final double size;
  final bool isOnline;
  final bool showBadge;

  const RadicalAvatarFrame({
    super.key,
    required this.avatarAssetPath,
    this.tier = RadicalFrameTier.none,
    this.size = 72,
    this.isOnline = false,
    this.showBadge = true,
  });

  @override
  State<RadicalAvatarFrame> createState() => _RadicalAvatarFrameState();
}

class _RadicalAvatarFrameState extends State<RadicalAvatarFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = RadicalFrameData.of(widget.tier);
    final animated = data.isAnimated;

    return SizedBox(
      width: widget.size + 20,
      height: widget.size + 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final rotation = animated ? _controller.value * math.pi * 2 : 0.0;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (widget.tier != RadicalFrameTier.none)
                Transform.rotate(
                  angle: rotation,
                  child: Container(
                    width: widget.size + 12,
                    height: widget.size + 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(colors: data.gradientColors),
                      boxShadow: [
                        BoxShadow(
                          color: data.glowColor,
                          blurRadius: animated ? 22 : 14,
                          spreadRadius: animated ? 3 : 1,
                        ),
                      ],
                    ),
                  ),
                ),
              Container(
                width: widget.size + 3,
                height: widget.size + 3,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RadicalTheme.ink,
                  border: widget.tier == RadicalFrameTier.none
                      ? Border.all(color: RadicalTheme.line)
                      : null,
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.avatarAssetPath,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: RadicalTheme.panel2,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person_rounded,
                        size: widget.size * .46,
                        color: RadicalTheme.goldBright,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.isOnline)
                Positioned(
                  right: 3,
                  bottom: 5,
                  child: Container(
                    width: math.max(10, widget.size * .15),
                    height: math.max(10, widget.size * .15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF48D597),
                      shape: BoxShape.circle,
                      border: Border.all(color: RadicalTheme.ink, width: 2),
                    ),
                  ),
                ),
              if (widget.showBadge && data.badgeIcon != null && widget.tier != RadicalFrameTier.none)
                Positioned(
                  left: -1,
                  top: 1,
                  child: Container(
                    width: math.max(18, widget.size * .25),
                    height: math.max(18, widget.size * .25),
                    decoration: BoxDecoration(
                      color: RadicalTheme.ink,
                      shape: BoxShape.circle,
                      border: Border.all(color: data.gradientColors.first, width: 1.5),
                    ),
                    child: Icon(
                      data.badgeIcon,
                      size: widget.size * .15,
                      color: data.gradientColors.first,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
