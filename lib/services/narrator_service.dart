import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// رویدادهایی که راوی اعلام می‌کند. نام فایل = نام enum + .mp3
/// فایل‌ها را در assets/audio/narrator/ بگذار.
enum NarratorLine {
  gameStart,
  nightStart,
  mafiaWake,
  mafiaSleep,
  doctorWake,
  doctorSleep,
  detectiveWake,
  detectiveSleep,
  dayStart,
  nobodyDied,
  someoneDied,
  discussionStart,
  votingStart,
  playerEliminated,
  mafiaWin,
  citizensWin,
  independentWin,
}

/// متن فارسی هر جمله (برای ضبط یا تبدیل متن به گفتار)
const narratorTexts = <NarratorLine, String>{
  NarratorLine.gameStart: 'بازی آغاز شد. نقش‌ها به شما داده شد.',
  NarratorLine.nightStart: 'شب فرا رسید. همه به خواب بروند.',
  NarratorLine.mafiaWake: 'مافیا بیدار شود و قربانی خود را انتخاب کند.',
  NarratorLine.mafiaSleep: 'مافیا به خواب رفت.',
  NarratorLine.doctorWake: 'دکتر بیدار شود و یک نفر را نجات دهد.',
  NarratorLine.doctorSleep: 'دکتر به خواب رفت.',
  NarratorLine.detectiveWake: 'کارآگاه بیدار شود و استعلام بگیرد.',
  NarratorLine.detectiveSleep: 'کارآگاه به خواب رفت.',
  NarratorLine.dayStart: 'روز شد. همه بیدار شوند.',
  NarratorLine.nobodyDied: 'دیشب هیچ‌کس کشته نشد.',
  NarratorLine.someoneDied: 'دیشب یک نفر کشته شد.',
  NarratorLine.discussionStart: 'زمان بحث و گفتگو آغاز شد.',
  NarratorLine.votingStart: 'زمان رأی‌گیری است.',
  NarratorLine.playerEliminated: 'با رأی مردم، یک نفر از بازی خارج شد.',
  NarratorLine.mafiaWin: 'مافیا پیروز شد.',
  NarratorLine.citizensWin: 'شهروندان پیروز شدند.',
  NarratorLine.independentWin: 'نقش مستقل پیروز شد.',
};

/// پخش صدای راوی با صف: جمله‌ها پشت سر هم پخش می‌شوند و روی هم نمی‌افتند.
///
/// pubspec.yaml:
///   dependencies:
///     audioplayers: ^6.0.0
///   flutter:
///     assets:
///       - assets/audio/narrator/
///
/// استفاده:
///   await NarratorService.instance.play(NarratorLine.nightStart);
///   await NarratorService.instance.playAll([
///     NarratorLine.nightStart, NarratorLine.mafiaWake]);
class NarratorService {
  NarratorService._();
  static final instance = NarratorService._();

  final AudioPlayer _player = AudioPlayer();
  final List<NarratorLine> _queue = [];
  bool _busy = false;
  bool enabled = true;
  double _volume = 1.0;

  double get volume => _volume;
  set volume(double v) {
    _volume = v.clamp(0.0, 1.0);
    _player.setVolume(_volume);
  }

  /// یک جمله را به صف اضافه می‌کند.
  Future<void> play(NarratorLine line) => playAll([line]);

  Future<void> playAll(List<NarratorLine> lines) async {
    if (!enabled) return;
    _queue.addAll(lines);
    if (_busy) return;
    _busy = true;
    try {
      while (_queue.isNotEmpty) {
        final line = _queue.removeAt(0);
        await _playOne(line);
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> _playOne(NarratorLine line) async {
    final done = Completer<void>();
    late StreamSubscription sub;
    sub = _player.onPlayerComplete.listen((_) {
      if (!done.isCompleted) done.complete();
    });
    try {
      await _player.setVolume(_volume);
      await _player.play(AssetSource('audio/narrator/${line.name}.mp3'));
      // اگر فایل وجود نداشت یا خطا شد، بیش از ۲۰ ثانیه منتظر نمی‌مانیم.
      await done.future.timeout(const Duration(seconds: 20));
    } catch (_) {
      // فایل صوتی نبود؛ بازی ادامه پیدا کند.
    } finally {
      await sub.cancel();
    }
  }

  /// قطع فوری و پاک کردن صف (مثلاً وقتی بازیکن از بازی خارج می‌شود).
  Future<void> stop() async {
    _queue.clear();
    await _player.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
