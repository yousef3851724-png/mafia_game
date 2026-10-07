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
  static final List<StoreItem> stickers = <StoreItem>[
    StoreItem(id: 'sa01', category: StoreCategory.sticker, nameFa: 'با من میگیری؟', price: 300, assetPath: 'assets/stickers/set_1/sticker_01.png'),
    StoreItem(id: 'sa02', category: StoreCategory.sticker, nameFa: 'صدات نمیاد', price: 300, assetPath: 'assets/stickers/set_1/sticker_02.png'),
    StoreItem(id: 'sa03', category: StoreCategory.sticker, nameFa: 'داره جک میگه', price: 300, assetPath: 'assets/stickers/set_1/sticker_03.png'),
    StoreItem(id: 'sa04', category: StoreCategory.sticker, nameFa: 'صددرصد مافیایی', price: 800, assetPath: 'assets/stickers/set_1/sticker_04.png'),
    StoreItem(id: 'sa05', category: StoreCategory.sticker, nameFa: 'باهاش چشمم باز کردی', price: 300, assetPath: 'assets/stickers/set_1/sticker_05.png'),
    StoreItem(id: 'sa06', category: StoreCategory.sticker, nameFa: 'خیلی شوی', price: 300, assetPath: 'assets/stickers/set_1/sticker_06.png'),
    StoreItem(id: 'sa07', category: StoreCategory.sticker, nameFa: 'کلس کردی باز', price: 300, assetPath: 'assets/stickers/set_1/sticker_07.png'),
    StoreItem(id: 'sa08', category: StoreCategory.sticker, nameFa: 'برو به درک', price: 300, assetPath: 'assets/stickers/set_1/sticker_08.png'),
    StoreItem(id: 'sa09', category: StoreCategory.sticker, nameFa: 'حق با توئه', price: 300, assetPath: 'assets/stickers/set_1/sticker_09.png'),
    StoreItem(id: 'sa10', category: StoreCategory.sticker, nameFa: 'عالیه', price: 300, assetPath: 'assets/stickers/set_1/sticker_10.png'),
    StoreItem(id: 'sa11', category: StoreCategory.sticker, nameFa: 'رفاقت مهمه', price: 300, assetPath: 'assets/stickers/set_1/sticker_11.png'),
    StoreItem(id: 'sa12', category: StoreCategory.sticker, nameFa: 'سکوت کن', price: 300, assetPath: 'assets/stickers/set_1/sticker_12.png'),
    StoreItem(id: 'sa13', category: StoreCategory.sticker, nameFa: 'ملکه بازی', price: 800, assetPath: 'assets/stickers/set_1/sticker_13.png'),
    StoreItem(id: 'sa14', category: StoreCategory.sticker, nameFa: 'عقلم میگه برو جلو', price: 300, assetPath: 'assets/stickers/set_1/sticker_14.png'),
    StoreItem(id: 'sa15', category: StoreCategory.sticker, nameFa: 'شک دارم', price: 300, assetPath: 'assets/stickers/set_1/sticker_15.png'),
    StoreItem(id: 'sa16', category: StoreCategory.sticker, nameFa: 'فکر کن', price: 300, assetPath: 'assets/stickers/set_1/sticker_16.png'),
    StoreItem(id: 'sa17', category: StoreCategory.sticker, nameFa: 'تک‌تیرانداز', price: 300, assetPath: 'assets/stickers/set_1/sticker_17.png'),
    StoreItem(id: 'sa18', category: StoreCategory.sticker, nameFa: 'مامور مخفی', price: 300, assetPath: 'assets/stickers/set_1/sticker_18.png'),
    StoreItem(id: 'sa19', category: StoreCategory.sticker, nameFa: 'به سلامتی', price: 300, assetPath: 'assets/stickers/set_1/sticker_19.png'),
    StoreItem(id: 'sa20', category: StoreCategory.sticker, nameFa: 'بازی ادامه داره', price: 300, assetPath: 'assets/stickers/set_1/sticker_20.png'),
    StoreItem(id: 'sa21', category: StoreCategory.sticker, nameFa: 'مراقب باش', price: 300, assetPath: 'assets/stickers/set_1/sticker_21.png'),
    StoreItem(id: 'sa22', category: StoreCategory.sticker, nameFa: 'من نمی‌دونم', price: 300, assetPath: 'assets/stickers/set_1/sticker_22.png'),
    StoreItem(id: 'sa23', category: StoreCategory.sticker, nameFa: 'تایید می‌کنم', price: 300, assetPath: 'assets/stickers/set_1/sticker_23.png'),
    StoreItem(id: 'sa24', category: StoreCategory.sticker, nameFa: 'کلاغ پرواز کرد', price: 300, assetPath: 'assets/stickers/set_1/sticker_24.png'),
    StoreItem(id: 'sa25', category: StoreCategory.sticker, nameFa: 'بزن بریم', price: 300, assetPath: 'assets/stickers/set_1/sticker_25.png'),
    StoreItem(id: 'sa26', category: StoreCategory.sticker, nameFa: 'شب بخیر', price: 300, assetPath: 'assets/stickers/set_1/sticker_26.png'),
    StoreItem(id: 'sa27', category: StoreCategory.sticker, nameFa: 'فقط ما', price: 300, assetPath: 'assets/stickers/set_1/sticker_27.png'),
    StoreItem(id: 'sa28', category: StoreCategory.sticker, nameFa: 'دلم شکسته', price: 300, assetPath: 'assets/stickers/set_1/sticker_28.png'),
    StoreItem(id: 'sa29', category: StoreCategory.sticker, nameFa: 'بزن کنار', price: 300, assetPath: 'assets/stickers/set_1/sticker_29.png'),
    StoreItem(id: 'sa30', category: StoreCategory.sticker, nameFa: 'دست نگه‌دار', price: 300, assetPath: 'assets/stickers/set_1/sticker_30.png'),
    StoreItem(id: 'sa31', category: StoreCategory.sticker, nameFa: 'پادشاه بازی', price: 800, assetPath: 'assets/stickers/set_1/sticker_31.png'),
    StoreItem(id: 'sa32', category: StoreCategory.sticker, nameFa: 'بیا حرف بزن', price: 300, assetPath: 'assets/stickers/set_1/sticker_32.png'),
    StoreItem(id: 'sa33', category: StoreCategory.sticker, nameFa: 'مطمئنم', price: 300, assetPath: 'assets/stickers/set_1/sticker_33.png'),
    StoreItem(id: 'sa34', category: StoreCategory.sticker, nameFa: 'هم شکه هم الماس', price: 800, assetPath: 'assets/stickers/set_1/sticker_34.png'),
    StoreItem(id: 'sb01', category: StoreCategory.sticker, nameFa: 'خوب بازی کن', price: 200, assetPath: 'assets/stickers/set_2/sticker_01.png'),
    StoreItem(id: 'sb02', category: StoreCategory.sticker, nameFa: 'حرف درست', price: 200, assetPath: 'assets/stickers/set_2/sticker_02.png'),
    StoreItem(id: 'sb03', category: StoreCategory.sticker, nameFa: 'گرگ درون', price: 600, assetPath: 'assets/stickers/set_2/sticker_03.png'),
    StoreItem(id: 'sb04', category: StoreCategory.sticker, nameFa: 'بزن بریم', price: 200, assetPath: 'assets/stickers/set_2/sticker_04.png'),
    StoreItem(id: 'sb05', category: StoreCategory.sticker, nameFa: 'پادشاه بازی', price: 600, assetPath: 'assets/stickers/set_2/sticker_05.png'),
    StoreItem(id: 'sb06', category: StoreCategory.sticker, nameFa: 'کافیه', price: 200, assetPath: 'assets/stickers/set_2/sticker_06.png'),
    StoreItem(id: 'sb07', category: StoreCategory.sticker, nameFa: 'مواظب باش', price: 200, assetPath: 'assets/stickers/set_2/sticker_07.png'),
    StoreItem(id: 'sb08', category: StoreCategory.sticker, nameFa: 'پول حرف میزنه', price: 200, assetPath: 'assets/stickers/set_2/sticker_08.png'),
    StoreItem(id: 'sb09', category: StoreCategory.sticker, nameFa: 'خوش‌شانس', price: 200, assetPath: 'assets/stickers/set_2/sticker_09.png'),
    StoreItem(id: 'sb10', category: StoreCategory.sticker, nameFa: 'بلف نزن', price: 200, assetPath: 'assets/stickers/set_2/sticker_10.png'),
    StoreItem(id: 'sb11', category: StoreCategory.sticker, nameFa: 'سکوت', price: 200, assetPath: 'assets/stickers/set_2/sticker_11.png'),
    StoreItem(id: 'sb12', category: StoreCategory.sticker, nameFa: 'اینو جدی بگیر', price: 200, assetPath: 'assets/stickers/set_2/sticker_12.png'),
    StoreItem(id: 'sb13', category: StoreCategory.sticker, nameFa: 'فکر کن', price: 200, assetPath: 'assets/stickers/set_2/sticker_13.png'),
    StoreItem(id: 'sb14', category: StoreCategory.sticker, nameFa: 'شب می‌رسد', price: 200, assetPath: 'assets/stickers/set_2/sticker_14.png'),
    StoreItem(id: 'sb15', category: StoreCategory.sticker, nameFa: 'عالیه', price: 200, assetPath: 'assets/stickers/set_2/sticker_15.png'),
    StoreItem(id: 'sb16', category: StoreCategory.sticker, nameFa: 'ساکت باش', price: 200, assetPath: 'assets/stickers/set_2/sticker_16.png'),
    StoreItem(id: 'sb17', category: StoreCategory.sticker, nameFa: 'مراقب باش', price: 200, assetPath: 'assets/stickers/set_2/sticker_17.png'),
    StoreItem(id: 'sb18', category: StoreCategory.sticker, nameFa: 'دلم شکسته', price: 200, assetPath: 'assets/stickers/set_2/sticker_18.png'),
    StoreItem(id: 'sb19', category: StoreCategory.sticker, nameFa: 'به‌تم', price: 200, assetPath: 'assets/stickers/set_2/sticker_19.png'),
    StoreItem(id: 'sb20', category: StoreCategory.sticker, nameFa: 'شروع کن', price: 200, assetPath: 'assets/stickers/set_2/sticker_20.png'),
    StoreItem(id: 'sb21', category: StoreCategory.sticker, nameFa: 'خخخ', price: 200, assetPath: 'assets/stickers/set_2/sticker_21.png'),
    StoreItem(id: 'sb22', category: StoreCategory.sticker, nameFa: 'مطمئنم', price: 200, assetPath: 'assets/stickers/set_2/sticker_22.png'),
    StoreItem(id: 'sb23', category: StoreCategory.sticker, nameFa: 'هدف', price: 200, assetPath: 'assets/stickers/set_2/sticker_23.png'),
    StoreItem(id: 'sb24', category: StoreCategory.sticker, nameFa: 'تارگت شدی', price: 200, assetPath: 'assets/stickers/set_2/sticker_24.png'),
    StoreItem(id: 'sb25', category: StoreCategory.sticker, nameFa: 'بیا اینجا', price: 200, assetPath: 'assets/stickers/set_2/sticker_25.png'),
    StoreItem(id: 'sb26', category: StoreCategory.sticker, nameFa: 'شک دارم', price: 200, assetPath: 'assets/stickers/set_2/sticker_26.png'),
    StoreItem(id: 'sb27', category: StoreCategory.sticker, nameFa: 'بفرما', price: 200, assetPath: 'assets/stickers/set_2/sticker_27.png'),
    StoreItem(id: 'sb28', category: StoreCategory.sticker, nameFa: 'بازنشینی', price: 600, assetPath: 'assets/stickers/set_2/sticker_28.png'),
    StoreItem(id: 'sb29', category: StoreCategory.sticker, nameFa: 'بازی تمومه', price: 200, assetPath: 'assets/stickers/set_2/sticker_29.png'),
    StoreItem(id: 'sb30', category: StoreCategory.sticker, nameFa: 'افسانه‌ای', price: 600, assetPath: 'assets/stickers/set_2/sticker_30.png'),
  ];
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
