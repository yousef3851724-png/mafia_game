import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../avatar_frame_widget.dart';
import '../../constants/frame_catalog.dart';

class AnimatedAvatarFrame extends StatefulWidget {
  final String? imageUrl;
  final String fallbackInitial;
  final FrameType frameType;
  final double size;
  final bool isAlive;
  final bool isSpeaking;
  final VoidCallback? onTap;

  const AnimatedAvatarFrame({
    super.key,
    this.imageUrl,
    this.fallbackInitial = '?',
    this.frameType = FrameType.none,
    this.size = 76.0,
    this.isAlive = true,
    this.isSpeaking = false,
    this.onTap,
  });

  @override
  State<AnimatedAvatarFrame> createState() => _AnimatedAvatarFrameState();
}

class _AnimatedAvatarFrameState extends State<AnimatedAvatarFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final meta = FrameCatalog.frames[widget.frameType] ?? FrameCatalog.frames[FrameType.none]!;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (2000 / meta.animationSpeed).round()),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedAvatarFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frameType != widget.frameType) {
      final meta = FrameCatalog.frames[widget.frameType] ?? FrameCatalog.frames[FrameType.none]!;
      _controller.duration = Duration(milliseconds: (2000 / meta.animationSpeed).round());
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = FrameCatalog.frames[widget.frameType] ?? FrameCatalog.frames[FrameType.none]!;
    final colors = meta.gradientColors.map((c) => Color(c)).toList();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isSpeaking && widget.isAlive)
                Container(
                  width: widget.size + 24,
                  height: widget.size + 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.greenAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.5),
                        blurRadius: 16,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                ),

              if (widget.frameType != FrameType.none && widget.isAlive)
                Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: widget.size + 14,
                    height: widget.size + 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [...colors, colors.first],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.first.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E1E24),
                  border: Border.all(
                    color: widget.isAlive ? Colors.black : Colors.grey.shade800,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallback(),
                        )
                      : _buildFallback(),
                ),
              ),

              if (!widget.isAlive)
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: const Icon(
                    Icons.clear_rounded,
                    color: Colors.redAccent,
                    size: 38,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        widget.fallbackInitial.isNotEmpty ? widget.fallbackInitial[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: widget.size * 0.38,
          fontWeight: FontWeight.w900,
          color: widget.isAlive ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}
