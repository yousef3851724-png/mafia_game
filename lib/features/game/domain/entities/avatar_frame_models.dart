enum CosmeticRarity {
  common,
  rare,
  epic,
  legendary,
  radical,
  seasonal,
  exclusive,
}

enum CosmeticType {
  avatar,
  frame,
}

class CosmeticItem {
  final String id;
  final String name;
  final CosmeticType type;
  final CosmeticRarity rarity;

  /// قیمت خرید با سکه
  int price;

  /// آیا قابل خرید است؟
  bool purchasable;

  /// آیا در فروشگاه نمایش داده شود؟
  bool visible;

  /// آیا فقط در فصل/رویداد قابل دریافت است؟
  bool seasonal;

  /// سطح موردنیاز برای باز شدن
  int requiredLevel;

  /// درصد تخفیف
  int discountPercent;

  CosmeticItem({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.price,
    this.purchasable = true,
    this.visible = true,
    this.seasonal = false,
    this.requiredLevel = 0,
    this.discountPercent = 0,
  });

  int get finalPrice {
    if (discountPercent <= 0) {
      return price;
    }

    final discount = price * discountPercent ~/ 100;
    return price - discount;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'rarity': rarity.name,
      'price': price,
      'purchasable': purchasable,
      'visible': visible,
      'seasonal': seasonal,
      'requiredLevel': requiredLevel,
      'discountPercent': discountPercent,
    };
  }

  factory CosmeticItem.fromJson(Map<String, dynamic> json) {
    return CosmeticItem(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CosmeticType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      rarity: CosmeticRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
      ),
      price: json['price'] as int,
      purchasable: json['purchasable'] ?? true,
      visible: json['visible'] ?? true,
      seasonal: json['seasonal'] ?? false,
      requiredLevel: json['requiredLevel'] ?? 0,
      discountPercent: json['discountPercent'] ?? 0,
    );
  }
}