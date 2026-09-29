import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/app_providers.dart';

const _gold = Color(0xFFE3B873);
const _goldBright = Color(0xFFFFD86B);

const List<int> _segments = [20, 50, 30, 100, 20, 150, 50, 200, 30, 100, 50, 500];

const Map<int, int> _weights = {
  20: 24, 30: 22, 50: 20, 100: 16, 150: 9, 200: 7, 500: 2,
};

const _prefKey = 'lucky_wheel_last_spin';
const _cooldown = Duration(hours: 24);

class LuckyWheelScreen extends ConsumerStatefulWidget {
  const LuckyWheelScreen({super.key});

  @override
  ConsumerState<LuckyWheelScreen> createState() => _LuckyWheelScreenState();
}

class _LuckyWheelScreenState extends ConsumerState<LuckyWheelScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rand = math.Random();
  double _angle = 0;
  bool _spinning = false;
  int? _lastSpinMs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _lastSpinMs = p.getInt(_prefKey));
  }

  Duration get _remaining {
    if (_lastSpinMs == null) return Duration.zero;
    final passed = DateTime.now().millisecondsSinceEpoch - _lastSpinMs!;
    final left = _cooldown.inMilliseconds - passed;
    return left > 0 ? Duration(milliseconds: left) : Duration.zero;
  }

  bool get _canSpin => !_spinning && _remaining == Duration.zero;

  int _pickIndex() {
    var roll = _rand.nextInt(100);
    var prize = 20;
    for (final e in _weights.entries) {
      if (roll < e.value) {
        prize = e.key;
        break;
      }
      roll -= e.value;
    }
    final idx = <int>[
      for (var i = 0; i < _segments.length; i++)
        if (_segments[i] == prize) i
    ];
    return idx[_rand.nextInt(idx.length)];
  }

  Future<void> _spin() async {
    if (!_canSpin) return;
    final index = _pickIndex();
    final prize = _segments[index];
    final step = 2 * math.pi / _segments.length;
    const full = 2 * math.pi;

    final jitter = (_rand.nextDouble() - .5) * step * .6;
    final targetMod = (full - (index + .5) * step + jitter) % full;
    final cur = _angle % full;
    final delta = ((targetMod - cur) % full) + 5 * full;
    final start = _angle;
    final end = _angle + delta;

    setState(() => _spinning = true);
    final now = DateTime.now().millisecondsSinceEpoch;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefKey, now);
    _lastSpinMs = now;

    final anim = Tween<double>(begin: start, end: end)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    void listener() => setState(() => _angle = anim.value);
    anim.addListener(listener);
    _ctrl.reset();
    await _ctrl.forward();
    anim.removeListener(listener);

    if (!mounted) return;
    setState(() {
      _angle = end;
      _spinning = false;
    });

    ref.read(walletProvider.notifier).update(
          (w) => RadicalWallet(coins: w.coins + prize, diamonds: w.diamonds),
        );
    _showResult(prize);
  }

  void _showResult(int prize) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF14141C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _gold),
        ),
        title: Text(prize == 500 ? 'شانس طلایی! 🎉' : 'تبریک! 🎉',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _goldBright)),
        content: Text('$prize سکه برنده شدی',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('باشه', style: TextStyle(color: _gold)),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final canSpin = _canSpin;
    final width = MediaQuery.of(context).size.width;
    final wheelSize = math.min(width - 48, 340.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _gold),
        title: const Text('گردونه شانس روزانه',
            style: TextStyle(color: _goldBright, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14141C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _gold.withValues(alpha: .4)),
                  ),
                  child: const Text(
                    'هر روز یک بار رایگان بچرخان؛ شانس طلایی ۵۰۰ سکه!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: wheelSize,
                  height: wheelSize + 20,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 20,
                        child: SizedBox(
                          width: wheelSize,
                          height: wheelSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: Size(wheelSize, wheelSize),
                                painter: _WheelPainter(_angle),
                              ),
                              Container(
                                width: wheelSize * .24,
                                height: wheelSize * .24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0B0B12),
                                  border: Border.all(color: _gold, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                        color: _gold.withValues(alpha: .5),
                                        blurRadius: 16),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/logo/radical_face_only.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.casino_rounded,
                                        color: _goldBright),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down_rounded,
                          size: 56, color: _goldBright),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('جایزه ویژه',
                    style: TextStyle(color: _gold, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('500 🪙',
                    style: TextStyle(
                        color: _goldBright,
                        fontSize: 30,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(canSpin ? 'فرصت‌های امروز: ۱' : 'فرصت‌های امروز: ۰',
                    style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canSpin ? _spin : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      disabledBackgroundColor: const Color(0xFF2A2A33),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _spinning ? 'در حال چرخش...' : 'چرخش رایگان',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (!canSpin && !_spinning) ...[
                  const SizedBox(height: 10),
                  Text('چرخش بعدی: ${_fmt(_remaining)}',
                      style: const TextStyle(color: Colors.white38)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final double angle;
  _WheelPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final n = _segments.length;
    final step = 2 * math.pi / n;
    final rect = Rect.fromCircle(center: Offset.zero, radius: r - 6);

    canvas.save();
    canvas.translate(r, r);
    canvas.rotate(angle);

    for (var i = 0; i < n; i++) {
      final isGold = _segments[i] == 500;
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = isGold
            ? const Color(0xFFC9962E)
            : (i.isEven ? const Color(0xFF5B2A9E) : const Color(0xFF2A1450));
      canvas.drawArc(rect, -math.pi / 2 + i * step, step, true, fill);

      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _gold.withValues(alpha: .6);
      canvas.drawArc(rect, -math.pi / 2 + i * step, step, true, line);

      final tp = TextPainter(
        text: TextSpan(
          text: '${_segments[i]}',
          style: TextStyle(
            color: isGold ? Colors.black : _goldBright,
            fontSize: isGold ? 24 : 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.rotate(-math.pi / 2 + (i + .5) * step);
      canvas.translate(r * .68, 0);
      canvas.rotate(math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = _gold;
    canvas.drawCircle(Offset.zero, r - 4, ring);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => old.angle != angle;
}
