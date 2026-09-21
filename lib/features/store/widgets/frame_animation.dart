import 'package:flutter/material.dart';
import '../../../core/theme/radical_frame_tier.dart';
import '../../../core/theme/radical_theme.dart';

class FramePurchaseAnimation extends StatefulWidget {
  final RadicalFrameTier tier;
  final VoidCallback onComplete;

  const FramePurchaseAnimation({
    super.key,
    required this.tier,
    required this.onComplete,
  });

  @override
  State<FramePurchaseAnimation> createState() => _FramePurchaseAnimationState();
}

class _FramePurchaseAnimationState extends State<FramePurchaseAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
      ),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Color(widget.tier.color), width: 3),
          boxShadow: [
            BoxShadow(
              color: Color(widget.tier.color).withOpacity(0.8),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '✓',
            style: TextStyle(
              fontSize: 80,
              color: Color(widget.tier.color),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
