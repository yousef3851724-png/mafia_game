cat > lib/widgets/radical_avatar_frame.dart << 'EOF'
import 'package:flutter/material.dart';
import '../models/radical_avatar_frame_model.dart';
import 'radical_frame_painter.dart';

class RadicalAvatarFrame extends StatefulWidget {
  final String avatarAssetPath;
  final RadicalFrameTier tier;
  final double size;
  final bool isOnline;

  const RadicalAvatarFrame({
    super.key,
    required this.avatarAssetPath,
    required this.tier,
    this.size = 64.0,
    this.isOnline = false,
  });

  @override
  State<RadicalAvatarFrame> createState() => _RadicalAvatarFrameState();
}

class _RadicalAvatarFrameState extends State<RadicalAvatarFrame> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              widget.avatarAssetPath,
              width: widget.size - 12,
              height: widget.size - 12,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: widget.size - 12,
                  height: widget.size - 12,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.person, color: Colors.white54),
                );
              },
            ),
          ),
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: RadicalFramePainter(
              tier: widget.tier,
              isOnline: widget.isOnline,
            ),
          ),
        ],
      ),
    );
  }
}
EOF
echo "✅ radical_avatar_frame.dart ساخته شد"
