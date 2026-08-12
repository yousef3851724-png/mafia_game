import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ReactionType {
  like,
  dislike,
  laugh,
  cry,
  none,
}

class ReactionButton extends StatefulWidget {
  final Function(ReactionType)? onReactionChanged;
  final double size;
  final bool showCount;

  const ReactionButton({
    super.key,
    this.onReactionChanged,
    this.size = 48,
    this.showCount = true,
  });

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton>
    with SingleTickerProviderStateMixin {
  ReactionType _currentReaction = ReactionType.none;
  int _likeCount = 0;
  int _dislikeCount = 0;
  int _laughCount = 0;
  int _cryCount = 0;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  List<Offset> _tearDrops = [];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleReaction(ReactionType type) {
    setState(() {
      if (_currentReaction == type) {
        _currentReaction = ReactionType.none;
        _decrementCount(type);
      } else {
        if (_currentReaction != ReactionType.none) {
          _decrementCount(_currentReaction);
        }
        _currentReaction = type;
        _incrementCount(type);
        _scaleController.forward(from: 0);
      }
      widget.onReactionChanged?.call(_currentReaction);
    });
  }

  void _incrementCount(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        _likeCount++;
        break;
      case ReactionType.dislike:
        _dislikeCount++;
        break;
      case ReactionType.laugh:
        _laughCount++;
        break;
      case ReactionType.cry:
        _cryCount++;
        _generateTears();
        break;
      case ReactionType.none:
        break;
    }
  }

  void _decrementCount(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        if (_likeCount > 0) _likeCount--;
        break;
      case ReactionType.dislike:
        if (_dislikeCount > 0) _dislikeCount--;
        break;
      case ReactionType.laugh:
        if (_laughCount > 0) _laughCount--;
        break;
      case ReactionType.cry:
        if (_cryCount > 0) _cryCount--;
        break;
      case ReactionType.none:
        break;
    }
  }

  void _generateTears() {
    _tearDrops = List.generate(6, (_) => Offset(
          -10 + 20 * (_ / 5),
          10 + 30 * (_ / 5),
        ));
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => _tearDrops.clear());
    });
  }

  String _getEmoji(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return '👍';
      case ReactionType.dislike:
        return '👎';
      case ReactionType.laugh:
        return '😂';
      case ReactionType.cry:
        return '😢';
      case ReactionType.none:
        return '❤️';
    }
  }

  Color _getColor(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return Colors.green;
      case ReactionType.dislike:
        return Colors.red;
      case ReactionType.laugh:
        return Colors.orange;
      case ReactionType.cry:
        return Colors.blue;
      case ReactionType.none:
        return Colors.grey;
    }
  }

  int _getCount(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return _likeCount;
      case ReactionType.dislike:
        return _dislikeCount;
      case ReactionType.laugh:
        return _laughCount;
      case ReactionType.cry:
        return _cryCount;
      case ReactionType.none:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            final next = {
              ReactionType.none: ReactionType.like,
              ReactionType.like: ReactionType.dislike,
              ReactionType.dislike: ReactionType.laugh,
              ReactionType.laugh: ReactionType.cry,
              ReactionType.cry: ReactionType.none,
            }[_currentReaction]!;
            _handleReaction(next);
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (ctx, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getColor(_currentReaction).withOpacity(0.15),
                    border: Border.all(
                      color: _currentReaction == ReactionType.none
                          ? Colors.grey.withOpacity(0.3)
                          : _getColor(_currentReaction),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        _getEmoji(_currentReaction),
                        style: TextStyle(fontSize: widget.size * 0.5),
                      ),
                      if (_currentReaction == ReactionType.like)
                        ...List.generate(8, (i) {
                          final angle = (i / 8) * 2 * 3.14159;
                          return Positioned(
                            left: widget.size / 2 +
                                (widget.size * 0.5) * 0.7 * cos(angle) -
                                4,
                            top: widget.size / 2 +
                                (widget.size * 0.5) * 0.7 * sin(angle) -
                                4,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow,
                              ),
                            ).animate().fadeOut(
                              duration: 600.ms,
                              delay: (i * 50).ms,
                            ),
                          );
                        }),
                      if (_currentReaction == ReactionType.cry)
                        for (var offset in _tearDrops)
                          Positioned(
                            left: widget.size / 2 + offset.dx - 3,
                            top: widget.size / 2 + offset.dy - 3,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                            ).animate().fadeOut(duration: 700.ms),
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showCount) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: ReactionType.values
                .where((t) => t != ReactionType.none && _getCount(t) > 0)
                .map((type) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_getEmoji(type), style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 2),
                          Text(
                            '${_getCount(type)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
