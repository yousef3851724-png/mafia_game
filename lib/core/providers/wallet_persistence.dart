import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_providers.dart';

/// ویجتی که دور کل برنامه قرار می‌گیرد:
/// موجودی را از حافظه می‌خواند و با هر تغییر ذخیره می‌کند.
class WalletPersistence extends ConsumerStatefulWidget {
  final Widget child;
  const WalletPersistence({super.key, required this.child});

  @override
  ConsumerState<WalletPersistence> createState() => _WalletPersistenceState();
}

class _WalletPersistenceState extends ConsumerState<WalletPersistence> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final coins = p.getInt('wallet_coins');
    final diamonds = p.getInt('wallet_diamonds');
    if (coins != null && diamonds != null) {
      // حالت تست سازنده: حداقل موجودی (برای نسخه نهایی حذف شود)
      ref.read(walletProvider.notifier).state = RadicalWallet(
        coins: coins < 100000 ? 100000 : coins,
        diamonds: diamonds < 10000 ? 10000 : diamonds,
      );
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save(RadicalWallet w) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('wallet_coins', w.coins);
    await p.setInt('wallet_diamonds', w.diamonds);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RadicalWallet>(walletProvider, (prev, next) {
      // تا قبل از خواندن مقدار ذخیره‌شده، چیزی نمی‌نویسیم
      if (_loaded) _save(next);
    });
    return widget.child;
  }
}
