import '../../core/avatars/avatar_catalog.dart';
import '../../core/theme/frame_catalog.dart';

enum StoreCategory { avatar, frame, sticker, gif, tombstone }

enum StoreCurrency { coins, diamonds }

class StoreItem {
  final String id;
  final StoreCategory category;
  final String nameFa;
  final int price;
  final String assetPath;
  final StoreCurrency currency;
  const StoreItem({
    required this.id,
    required this.category,
    required this.nameFa,
    required this.price,
    required this.assetPath,
    this.currency = StoreCurrency.diamonds,
  });
}

class StoreItems {
  // شماره آواتارهای لجندری (الماس)؛ بقیه معمولی (سکه)
  static const Set<int> _legendary = {3, 4, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24};
  static int _avatarPrice(int n) {
    if (n <= 2) return 3000;
    if (n == 3 || n == 4) return 1500;
    if (n <= 10) return 3000 + (n - 5) * 200;
    if (n <= 15) return 1500;
    if (n <= 20) return 1800;
    return 2000;
  }

  // price overrides in COINS (officers 3000, chef 4000, elders 5000, 22-24 cheap)
  static const Map<int, int> _coinOverrides = <int, int>{
    22: 500, 23: 500, 24: 500,
    15: 3000, 18: 3000, 19: 3500,
    49: 4000,
    13: 5000, 16: 5000, 20: 5000, 27: 5000, 39: 5000, 56: 5000, 70: 5000,
  };

  static final List<StoreItem> avatars = List.generate(
    AvatarCatalog.count,
    (i) => StoreItem(
      id: 'av${(i + 1).toString().padLeft(2, '0')}',
      category: StoreCategory.avatar,
      nameFa: 'آواتار ${i + 1}',
      price: _coinOverrides[i + 1] ?? _avatarPrice(i + 1),
      assetPath: AvatarCatalog.path(i),
      currency: _coinOverrides.containsKey(i + 1)
            ? StoreCurrency.coins
            : (_legendary.contains(i + 1)
                ? StoreCurrency.diamonds
                : StoreCurrency.coins),
    ),
  );

  static final List<StoreItem> frames = FrameCatalogPng.all
      .map((f) => StoreItem(
            id: f.id,
            category: StoreCategory.frame,
            nameFa: f.nameFa,
            price: f.price,
            assetPath: f.assetPath,
          ))
      .toList();

  // برای اضافه کردن آیتم جدید، فقط یک StoreItem به این لیست‌ها اضافه کن.
  static final List<StoreItem> stickers = <StoreItem>[];
  static final List<StoreItem> gifs = <StoreItem>[];
  static final List<StoreItem> tombstones = <StoreItem>[
    StoreItem(id: 'ts01', category: StoreCategory.tombstone, nameFa: 'کلاسیک', price: 300, assetPath: 'assets/tombstones/tombstone_01_classic.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts02', category: StoreCategory.tombstone, nameFa: 'صلیب', price: 500, assetPath: 'assets/tombstones/tombstone_02_cross.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts03', category: StoreCategory.tombstone, nameFa: 'ستون', price: 800, assetPath: 'assets/tombstones/tombstone_03_obelisk.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts04', category: StoreCategory.tombstone, nameFa: 'گوتیک', price: 1000, assetPath: 'assets/tombstones/tombstone_04_gothic.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts05', category: StoreCategory.tombstone, nameFa: 'جمجمه', price: 1500, assetPath: 'assets/tombstones/tombstone_05_skull.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts06', category: StoreCategory.tombstone, nameFa: 'رز', price: 2000, assetPath: 'assets/tombstones/tombstone_06_rose.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts07', category: StoreCategory.tombstone, nameFa: 'تاج', price: 3000, assetPath: 'assets/tombstones/tombstone_07_crown.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts08', category: StoreCategory.tombstone, nameFa: 'مافیا', price: 3500, assetPath: 'assets/tombstones/tombstone_08_mafia.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts09', category: StoreCategory.tombstone, nameFa: 'کلاغ', price: 4000, assetPath: 'assets/tombstones/tombstone_09_raven.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts10', category: StoreCategory.tombstone, nameFa: 'ماه', price: 600, assetPath: 'assets/tombstones/tombstone_10_moon.png', currency: StoreCurrency.diamonds),
    StoreItem(id: 'ts11', category: StoreCategory.tombstone, nameFa: 'مرمر', price: 900, assetPath: 'assets/tombstones/tombstone_11_marble.png', currency: StoreCurrency.diamonds),
    StoreItem(id: 'ts12', category: StoreCategory.tombstone, nameFa: 'طلایی', price: 1500, assetPath: 'assets/tombstones/tombstone_12_gold.png', currency: StoreCurrency.diamonds),
  ];

  static List<StoreItem> of(StoreCategory c) {
    switch (c) {
      case StoreCategory.avatar:
        return avatars;
      case StoreCategory.frame:
        return frames;
      case StoreCategory.sticker:
        return stickers;
      case StoreCategory.gif:
        return gifs;
      case StoreCategory.tombstone:
        return tombstones;
    }
  }
}
