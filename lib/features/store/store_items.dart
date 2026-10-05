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
    if (n <= 2) return 500;
    if (n == 3 || n == 4) return 1500;
    if (n <= 10) return 100 + (n - 5) * 20;
    if (n <= 15) return 1500;
    if (n <= 20) return 1800;
    return 2000;
  }

  static final List<StoreItem> avatars = List.generate(
    AvatarCatalog.count,
    (i) => StoreItem(
      id: 'av${(i + 1).toString().padLeft(2, '0')}',
      category: StoreCategory.avatar,
      nameFa: 'آواتار ${i + 1}',
      price: _avatarPrice(i + 1),
      assetPath: AvatarCatalog.path(i),
      currency: _legendary.contains(i + 1)
          ? StoreCurrency.diamonds
          : StoreCurrency.coins,
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
  static final List<StoreItem> tombstones = <StoreItem>[];

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
