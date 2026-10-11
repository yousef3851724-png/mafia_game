import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// پروفایل مستقل هر نصب: شناسه‌ی یکتا (UUID)، نام و کد رفرال.
/// فعلاً محلی است و بعداً به سرور وصل می‌شود.
class PlayerProfile {
  final String id;
  final String name;
  final String referralCode;
  final String? referredBy;
  final int level;

  const PlayerProfile({
    required this.id,
    required this.name,
    required this.referralCode,
    this.referredBy,
    this.level = 1,
  });

  PlayerProfile copyWith({String? name, String? referredBy, int? level}) =>
      PlayerProfile(
        id: id,
        name: name ?? this.name,
        referralCode: referralCode,
        referredBy: referredBy ?? this.referredBy,
        level: level ?? this.level,
      );
}

class PlayerProfileStore {
  static const _kId = 'player_id';
  static const _kName = 'player_name';
  static const _kRef = 'player_referral_code';
  static const _kReferredBy = 'player_referred_by';
  static const _kLevel = 'player_level';

  // حروف و اعداد بدون کاراکترهای شبیه هم (O/0، I/1)
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String _uuid() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final s = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${s.substring(0, 8)}-${s.substring(8, 12)}-'
        '${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
  }

  static String _newReferralCode() {
    final r = Random.secure();
    final code =
        List.generate(5, (_) => _alphabet[r.nextInt(_alphabet.length)]).join();
    return 'MR-$code';
  }

  static String _defaultName() =>
      'بازیکن_${1000 + Random.secure().nextInt(9000)}';

  /// اگر پروفایل وجود دارد می‌خواند، وگرنه اولین بار می‌سازد.
  static Future<PlayerProfile> loadOrCreate() async {
    final p = await SharedPreferences.getInstance();
    var id = p.getString(_kId);
    if (id == null || id.isEmpty) {
      id = _uuid();
      await p.setString(_kId, id);
    }
    var name = p.getString(_kName);
    if (name == null || name.trim().isEmpty) {
      name = _defaultName();
      await p.setString(_kName, name);
    }
    var ref = p.getString(_kRef);
    if (ref == null || ref.isEmpty) {
      ref = _newReferralCode();
      await p.setString(_kRef, ref);
    }
    return PlayerProfile(
      id: id,
      name: name,
      referralCode: ref,
      referredBy: p.getString(_kReferredBy),
      level: p.getInt(_kLevel) ?? 1,
    );
  }

  static Future<void> saveName(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, name.trim());
  }

  /// ثبت کد دوستِ دعوت‌کننده؛ فقط یک‌بار و نه کد خودِ بازیکن.
  /// نتیجه: null یعنی موفق، در غیر این صورت متن خطا.
  static Future<String?> applyReferral(String code, PlayerProfile me) async {
    final c = code.trim().toUpperCase();
    final ok = RegExp(r'^MR-[A-Z2-9]{5}$').hasMatch(c);
    if (!ok) return 'کد نامعتبر است';
    if (c == me.referralCode) return 'نمی‌توانید کد خودتان را وارد کنید';
    if (me.referredBy != null) return 'قبلاً کد دعوت ثبت کرده‌اید';
    final p = await SharedPreferences.getInstance();
    await p.setString(_kReferredBy, c);
    return null;
  }
}

/// نگهدارنده‌ی وضعیت پروفایل برای Riverpod.
class PlayerProfileNotifier extends StateNotifier<AsyncValue<PlayerProfile>> {
  PlayerProfileNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      state = AsyncValue.data(await PlayerProfileStore.loadOrCreate());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rename(String name) async {
    final cur = state.valueOrNull;
    if (cur == null || name.trim().isEmpty) return;
    await PlayerProfileStore.saveName(name);
    state = AsyncValue.data(cur.copyWith(name: name.trim()));
  }

  /// null یعنی موفق، در غیر این صورت پیام خطا
  Future<String?> useReferral(String code) async {
    final cur = state.valueOrNull;
    if (cur == null) return 'پروفایل آماده نیست';
    final err = await PlayerProfileStore.applyReferral(code, cur);
    if (err == null) {
      state = AsyncValue.data(cur.copyWith(referredBy: code.trim().toUpperCase()));
    }
    return err;
  }
}

final playerProfileProvider = StateNotifierProvider<PlayerProfileNotifier,
    AsyncValue<PlayerProfile>>((ref) => PlayerProfileNotifier());
