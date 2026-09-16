cat > lib/widgets/radical_avatar_frame.dart << 'EOF'
import 'package:flutter/material.dart';
import '../models/radical_avatar_frame_model.dart';
import 'radical_frame_painter.dart';

class RadicalAvatarFrame extends StatefulWidget {
  final String avatarAssetPath;
  final RadicalFrameTier tier;
  final double size;
  final bool isOnline;
  final bool showBadge;
  final VoidCallback? onTap;

  const RadicalAvatarFrame({
    super.key,
    required this.avatarAssetPath,
    this.tier = RadicalFrameTier.none,
    this.size = 84,
    this.isOnline = false,
    this.showBadge = true,
    this.onTap,
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
      duration: const Duration(seconds: 6),
    );
    if (RadicalFrameData.of(widget.tier).isAnimated) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant RadicalAvatarFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldAnimate = RadicalFrameData.of(widget.tier).isAnimated;
    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = RadicalFrameData.of(widget.tier);
    final frameSize = widget.size;
    final avatarSize = frameSize * 0.78;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: frameSize,
        height: frameSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(frameSize, frameSize),
                  painter: RadicalFramePainter(
                    gradientColors: data.gradientColors,
                    glowColor: data.glowColor,
                    strokeWidth: frameSize * 0.06,
                    rotationRadians: _controller.value * 6.28319,
                  ),
                );
              },
            ),
            ClipOval(
              child: Container(
                width: avatarSize,
                height: avatarSize,
                color: const Color(0xFF1A1A1A),
                child: Image.asset(
                  widget.avatarAssetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: avatarSize * 0.6,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            if (widget.showBadge && data.badgeIcon != null)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: data.gradientColors),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Icon(
                    data.badgeIcon,
                    size: frameSize * 0.16,
                    color: Colors.black,
                  ),
                ),
              ),
            if (widget.isOnline)
              Positioned(
                top: 0,
                right: frameSize * 0.05,
                child: Container(
                  width: frameSize * 0.14,
                  height: frameSize * 0.14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
EOF
echo "✅ radical_avatar_frame.dart ساخته شد"