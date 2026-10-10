import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/store/controllers/store_controller.dart';
import '../../features/store/store_items.dart';
import '../providers/app_providers.dart';

/// دسترسی ویژه‌ی مالک بازی (فریم‌های اختصاصی + الماس).
/// فقط با وارد کردن کد مالک (نگه‌داری به‌صورت هش SHA-256) فعال می‌شود.
/// نگهداری کد: پنهان، با فشار طولانی روی نام بازیکن در صفحه‌ی خانه.
class OwnerAccess {
  static const _codeHash =
      '14fb0868f9ce1b0839f458be0006fafe94aac73d809d494530e86f5ccc33ce41';
  static const ownerFrameIds = ['f36', 'f37'];
  static const grantCoins = 100000;
  static const grantDiamonds = 999999;

  /// true یعنی کد درست بود و دسترسی فعال شد.
  static Future<bool> tryUnlock(WidgetRef ref, String code) async {
    final digest = sha256.convert(utf8.encode(code.trim())).toString();
    if (digest != _codeHash) return false;

    final p = await SharedPreferences.getInstance();
    await p.setBool('owner_unlocked', true);

    final w = ref.read(walletProvider);
    ref.read(walletProvider.notifier).state = RadicalWallet(
      coins: math.max(w.coins, grantCoins),
      diamonds: math.max(w.diamonds, grantDiamonds),
    );
    await ref
        .read(storeControllerProvider.notifier)
        .grantOwned(StoreCategory.frame, ownerFrameIds, equipId: 'f37');
    return true;
  }
}
