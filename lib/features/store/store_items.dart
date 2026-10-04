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
  static const Set<int> _legendary = {3, 4};

  static final List<StoreItem> avatars = List.generate(
    AvatarCatalog.count,
    (i) => StoreItem(
      id: 'av${(i + 1).toString().padLeft(2, '0')}',
      category: StoreCategory.avatar,
      nameFa: 'آواتار ${i + 1}',
      price: _legendary.contains(i + 1) ? 1000 : 500,
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
  static final List<StoreItem> stickers = List.generate(
    8,
    (i) => StoreItem(
      id: 'st${(i + 1).toString().padLeft(2, '0')}',
      category: StoreCategory.sticker,
      nameFa: 'استیکر ${i + 1}',
      price: 500,
      assetPath: 'assets/stickers/set_1/sticker_${(i + 1).toString().padLeft(2, '0')}.png',
      currency: StoreCurrency.coins,
    ),
  );
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
