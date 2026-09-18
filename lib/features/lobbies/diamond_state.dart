import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lobby_system.dart';

class LobbyDiamondWallet {
  final Map<DiamondType, int> balances;
  const LobbyDiamondWallet(this.balances);

  factory LobbyDiamondWallet.initial() => const LobbyDiamondWallet({
        DiamondType.blue: 500,
        DiamondType.radical: 0,
        DiamondType.teen: 0,
        DiamondType.adult: 0,
      });

  int balance(DiamondType type) => balances[type] ?? 0;

  LobbyDiamondWallet copyWith(DiamondType type, int amount) => LobbyDiamondWallet({...balances, type: amount});
}

final diamondControllerProvider = NotifierProvider<DiamondController, LobbyDiamondWallet>(DiamondController.new);

class DiamondController extends Notifier<LobbyDiamondWallet> {
  @override
  LobbyDiamondWallet build() => LobbyDiamondWallet.initial();

  bool canSpend({required DiamondType type, required int amount}) => amount >= 0 && state.balance(type) >= amount;

  void grant(DiamondType type, int amount) {
    if (amount <= 0) return;
    state = state.copyWith(type, state.balance(type) + amount);
  }

  void spend(DiamondType type, int amount) {
    if (amount <= 0) return;
    if (!canSpend(type: type, amount: amount)) throw StateError('موجودی ${RadicalDiamonds.of(type).name} کافی نیست.');
    state = state.copyWith(type, state.balance(type) - amount);
  }

  void purchase(LobbyStoreItem item) => spend(item.currency, item.price);

  bool canEnterLobby(LobbyCategory category) {
    if (category.mode == LobbyMode.friendly && category.age == LobbyAge.adult) return state.balance(DiamondType.blue) > 0 || state.balance(DiamondType.adult) > 0;
    return RadicalDiamonds.supports(category, category.diamond) && state.balance(category.diamond) > 0;
  }

  void spendForLobby(LobbyCategory category) {
    final type = category.diamond;
    if (!RadicalDiamonds.supports(category, type)) throw StateError('این نوع الماس برای این لابی مجاز نیست.');
    spend(type, 1);
  }
}
