import 'avatar_frame_models.dart';

class CosmeticShopController {
  final List<CosmeticItem> items;

  int playerCoins;

  final Set<String> ownedItems = {};

  CosmeticShopController({
    required this.items,
    required this.playerCoins,
  });

  List<CosmeticItem> get visibleItems {
    return items
        .where((item) => item.visible)
        .toList();
  }

  bool canBuy(CosmeticItem item) {
    if (!item.visible) return false;
    if (!item.purchasable) return false;
    if (ownedItems.contains(item.id)) return false;

    return playerCoins >= item.finalPrice;
  }

  bool buy(CosmeticItem item) {
    if (!canBuy(item)) {
      return false;
    }

    playerCoins -= item.finalPrice;
    ownedItems.add(item.id);

    return true;
  }

  bool owns(String itemId) {
    return ownedItems.contains(itemId);
  }

  void addReward(String itemId) {
    final exists = items.any(
      (item) => item.id == itemId,
    );

    if (exists) {
      ownedItems.add(itemId);
    }
  }
}