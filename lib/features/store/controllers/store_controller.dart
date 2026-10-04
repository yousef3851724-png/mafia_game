import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/app_providers.dart';
import '../store_items.dart';

class StoreState {
  final Map<StoreCategory, Set<String>> owned;
  final Map<StoreCategory, String?> equipped;
  final String? message;
  const StoreState({this.owned = const {}, this.equipped = const {}, this.message});

  bool isOwned(StoreItem i) => owned[i.category]?.contains(i.id) ?? false;
  bool isEquipped(StoreItem i) => equipped[i.category] == i.id;
}

class StoreController extends StateNotifier<StoreState> {
  final Ref ref;
  StoreController(this.ref) : super(const StoreState()) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final owned = <StoreCategory, Set<String>>{};
    final equipped = <StoreCategory, String?>{};
    for (final c in StoreCategory.values) {
      owned[c] = (p.getStringList('store_owned_${c.name}') ?? []).toSet();
      equipped[c] = p.getString('store_equipped_${c.name}');
    }
    state = StoreState(owned: owned, equipped: equipped);
  }

  Future<void> _save(StoreCategory c) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('store_owned_${c.name}', (state.owned[c] ?? {}).toList());
    final e = state.equipped[c];
    if (e == null) {
      await p.remove('store_equipped_${c.name}');
    } else {
      await p.setString('store_equipped_${c.name}', e);
    }
  }

  Future<void> equip(StoreItem item) async {
    if (!state.isOwned(item)) return;
    state = StoreState(
      owned: state.owned,
      equipped: {...state.equipped, item.category: item.id},
    );
    await _save(item.category);
  }

  /// true یعنی خرید موفق بود.
  Future<bool> buy(StoreItem item) async {
    if (state.isOwned(item)) return false;
    final w = ref.read(walletProvider);
    final isCoins = item.currency == StoreCurrency.coins;
    final balance = isCoins ? w.coins : w.diamonds;
    if (balance < item.price) {
      state = StoreState(
        owned: state.owned,
        equipped: state.equipped,
        message: isCoins ? 'سکه کافی نیست' : 'الماس کافی نیست',
      );
      return false;
    }
    ref.read(walletProvider.notifier).state = RadicalWallet(
      coins: isCoins ? w.coins - item.price : w.coins,
      diamonds: isCoins ? w.diamonds : w.diamonds - item.price,
    );
    final set = {...(state.owned[item.category] ?? <String>{}), item.id};
    state = StoreState(
      owned: {...state.owned, item.category: set},
      equipped: {...state.equipped, item.category: item.id},
    );
    await _save(item.category);
    return true;
  }
}

final storeControllerProvider =
    StateNotifierProvider<StoreController, StoreState>((ref) => StoreController(ref));
