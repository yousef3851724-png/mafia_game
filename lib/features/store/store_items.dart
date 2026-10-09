import '../../core/avatars/avatar_catalog.dart';
import '../../core/theme/frame_catalog.dart';
import 'package:mafia_radical/data/avatar_catalog.dart';

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
    13: 5000,
    15: 3000,
    16: 5000,
    18: 3000,
    19: 3500,
    20: 5000,
    21: 1250,
    22: 500,
    23: 500,
    24: 500,
    25: 1000,
    26: 1250,
    27: 5000,
    28: 1750,
    29: 2000,
    30: 1000,
    31: 1250,
    32: 1500,
    33: 3000,
    34: 2000,
    35: 1000,
    36: 1250,
    37: 1500,
    38: 1750,
    39: 5000,
    40: 2500,
    41: 1250,
    42: 1500,
    43: 1750,
    44: 2000,
    45: 1000,
    46: 1250,
    47: 1500,
    48: 1750,
    49: 4000,
    50: 1000,
    51: 1250,
    52: 1500,
    53: 1750,
    54: 2500,
    55: 1000,
    56: 5000,
    57: 1500,
    58: 1750,
    59: 2000,
    60: 1000,
    61: 2500,
    62: 3000,
    63: 1750,
    64: 2000,
    65: 1000,
    66: 1250,
    67: 1500,
    68: 2500,
    69: 2000,
    70: 5000,
    71: 1250,
    72: 1500,
    73: 5000,
    74: 2000,
    75: 1000,
    76: 4500,
    77: 3000,
    78: 1750,
    79: 4000,
    80: 3500,
    81: 4500,
    82: 1500,
    83: 1750,
    84: 3500,
    85: 1000,
    86: 3000,
    87: 1500,
    88: 1750,
    89: 2000,
    90: 1000,
    91: 5000,
    92: 1500,
    93: 1750,
    94: 2000,
    95: 4000,
    96: 4500,
    97: 1500,
    98: 1750,
    99: 2000,
  };

  static final List<StoreItem> avatars = List.generate(
    kAvatarCatalog.length,
    (i) => StoreItem(
      id: 'av${(i + 1).toString().padLeft(2, '0')}',
      category: StoreCategory.avatar,
      nameFa: 'آواتار ${i + 1}',
      price: kAvatarCatalog[i].price,
      assetPath: kAvatarCatalog[i].asset,
      currency: StoreCurrency.coins,
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
      .toList()
    ..sort((a, b) {
      final c = a.price.compareTo(b.price);
      return c != 0 ? c : a.id.compareTo(b.id);
    });

  // برای اضافه کردن آیتم جدید، فقط یک StoreItem به این لیست‌ها اضافه کن.
  static final List<StoreItem> stickers = <StoreItem>[
    StoreItem(id: 'sa01', category: StoreCategory.sticker, nameFa: 'با من میگیری؟', price: 1500, assetPath: 'assets/stickers/set_1/sticker_01.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa02', category: StoreCategory.sticker, nameFa: 'صدات نمیاد', price: 1500, assetPath: 'assets/stickers/set_1/sticker_02.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa03', category: StoreCategory.sticker, nameFa: 'داره جک میگه', price: 1500, assetPath: 'assets/stickers/set_1/sticker_03.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa04', category: StoreCategory.sticker, nameFa: 'صددرصد مافیایی', price: 1500, assetPath: 'assets/stickers/set_1/sticker_04.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa05', category: StoreCategory.sticker, nameFa: 'باهاش چشمم باز کردی', price: 1500, assetPath: 'assets/stickers/set_1/sticker_05.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa06', category: StoreCategory.sticker, nameFa: 'خیلی شوی', price: 1500, assetPath: 'assets/stickers/set_1/sticker_06.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa07', category: StoreCategory.sticker, nameFa: 'کلس کردی باز', price: 1500, assetPath: 'assets/stickers/set_1/sticker_07.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa08', category: StoreCategory.sticker, nameFa: 'برو به درک', price: 1500, assetPath: 'assets/stickers/set_1/sticker_08.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa09', category: StoreCategory.sticker, nameFa: 'حق با توئه', price: 1500, assetPath: 'assets/stickers/set_1/sticker_09.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa10', category: StoreCategory.sticker, nameFa: 'عالیه', price: 1500, assetPath: 'assets/stickers/set_1/sticker_10.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa11', category: StoreCategory.sticker, nameFa: 'رفاقت مهمه', price: 1500, assetPath: 'assets/stickers/set_1/sticker_11.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa12', category: StoreCategory.sticker, nameFa: 'سکوت کن', price: 1500, assetPath: 'assets/stickers/set_1/sticker_12.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa13', category: StoreCategory.sticker, nameFa: 'ملکه بازی', price: 1500, assetPath: 'assets/stickers/set_1/sticker_13.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa14', category: StoreCategory.sticker, nameFa: 'عقلم میگه برو جلو', price: 1500, assetPath: 'assets/stickers/set_1/sticker_14.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa15', category: StoreCategory.sticker, nameFa: 'شک دارم', price: 1500, assetPath: 'assets/stickers/set_1/sticker_15.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa16', category: StoreCategory.sticker, nameFa: 'فکر کن', price: 1500, assetPath: 'assets/stickers/set_1/sticker_16.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa17', category: StoreCategory.sticker, nameFa: 'تک‌تیرانداز', price: 1500, assetPath: 'assets/stickers/set_1/sticker_17.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa18', category: StoreCategory.sticker, nameFa: 'مامور مخفی', price: 1500, assetPath: 'assets/stickers/set_1/sticker_18.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa19', category: StoreCategory.sticker, nameFa: 'به سلامتی', price: 1500, assetPath: 'assets/stickers/set_1/sticker_19.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa20', category: StoreCategory.sticker, nameFa: 'بازی ادامه داره', price: 1500, assetPath: 'assets/stickers/set_1/sticker_20.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa21', category: StoreCategory.sticker, nameFa: 'مراقب باش', price: 1500, assetPath: 'assets/stickers/set_1/sticker_21.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa22', category: StoreCategory.sticker, nameFa: 'من نمی‌دونم', price: 1500, assetPath: 'assets/stickers/set_1/sticker_22.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa23', category: StoreCategory.sticker, nameFa: 'تایید می‌کنم', price: 1500, assetPath: 'assets/stickers/set_1/sticker_23.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa24', category: StoreCategory.sticker, nameFa: 'کلاغ پرواز کرد', price: 1500, assetPath: 'assets/stickers/set_1/sticker_24.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa25', category: StoreCategory.sticker, nameFa: 'بزن بریم', price: 1500, assetPath: 'assets/stickers/set_1/sticker_25.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa26', category: StoreCategory.sticker, nameFa: 'شب بخیر', price: 1500, assetPath: 'assets/stickers/set_1/sticker_26.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa27', category: StoreCategory.sticker, nameFa: 'فقط ما', price: 1500, assetPath: 'assets/stickers/set_1/sticker_27.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa28', category: StoreCategory.sticker, nameFa: 'دلم شکسته', price: 1500, assetPath: 'assets/stickers/set_1/sticker_28.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa29', category: StoreCategory.sticker, nameFa: 'بزن کنار', price: 1500, assetPath: 'assets/stickers/set_1/sticker_29.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa30', category: StoreCategory.sticker, nameFa: 'دست نگه‌دار', price: 1500, assetPath: 'assets/stickers/set_1/sticker_30.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa31', category: StoreCategory.sticker, nameFa: 'پادشاه بازی', price: 1500, assetPath: 'assets/stickers/set_1/sticker_31.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa32', category: StoreCategory.sticker, nameFa: 'بیا حرف بزن', price: 1500, assetPath: 'assets/stickers/set_1/sticker_32.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa33', category: StoreCategory.sticker, nameFa: 'مطمئنم', price: 1500, assetPath: 'assets/stickers/set_1/sticker_33.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sa34', category: StoreCategory.sticker, nameFa: 'هم شکه هم الماس', price: 1500, assetPath: 'assets/stickers/set_1/sticker_34.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb01', category: StoreCategory.sticker, nameFa: 'خوب بازی کن', price: 1500, assetPath: 'assets/stickers/set_2/sticker_01.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb02', category: StoreCategory.sticker, nameFa: 'حرف درست', price: 1500, assetPath: 'assets/stickers/set_2/sticker_02.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb03', category: StoreCategory.sticker, nameFa: 'گرگ درون', price: 1500, assetPath: 'assets/stickers/set_2/sticker_03.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb04', category: StoreCategory.sticker, nameFa: 'بزن بریم', price: 1500, assetPath: 'assets/stickers/set_2/sticker_04.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb05', category: StoreCategory.sticker, nameFa: 'پادشاه بازی', price: 1500, assetPath: 'assets/stickers/set_2/sticker_05.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb06', category: StoreCategory.sticker, nameFa: 'کافیه', price: 1500, assetPath: 'assets/stickers/set_2/sticker_06.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb07', category: StoreCategory.sticker, nameFa: 'مواظب باش', price: 1500, assetPath: 'assets/stickers/set_2/sticker_07.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb08', category: StoreCategory.sticker, nameFa: 'پول حرف میزنه', price: 1500, assetPath: 'assets/stickers/set_2/sticker_08.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb09', category: StoreCategory.sticker, nameFa: 'خوش‌شانس', price: 1500, assetPath: 'assets/stickers/set_2/sticker_09.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb10', category: StoreCategory.sticker, nameFa: 'بلف نزن', price: 1500, assetPath: 'assets/stickers/set_2/sticker_10.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb11', category: StoreCategory.sticker, nameFa: 'سکوت', price: 1500, assetPath: 'assets/stickers/set_2/sticker_11.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb12', category: StoreCategory.sticker, nameFa: 'اینو جدی بگیر', price: 1500, assetPath: 'assets/stickers/set_2/sticker_12.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb13', category: StoreCategory.sticker, nameFa: 'فکر کن', price: 1500, assetPath: 'assets/stickers/set_2/sticker_13.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb14', category: StoreCategory.sticker, nameFa: 'شب می‌رسد', price: 1500, assetPath: 'assets/stickers/set_2/sticker_14.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb15', category: StoreCategory.sticker, nameFa: 'عالیه', price: 1500, assetPath: 'assets/stickers/set_2/sticker_15.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb16', category: StoreCategory.sticker, nameFa: 'ساکت باش', price: 1500, assetPath: 'assets/stickers/set_2/sticker_16.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb17', category: StoreCategory.sticker, nameFa: 'مراقب باش', price: 1500, assetPath: 'assets/stickers/set_2/sticker_17.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb18', category: StoreCategory.sticker, nameFa: 'دلم شکسته', price: 1500, assetPath: 'assets/stickers/set_2/sticker_18.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb19', category: StoreCategory.sticker, nameFa: 'به‌تم', price: 1500, assetPath: 'assets/stickers/set_2/sticker_19.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb20', category: StoreCategory.sticker, nameFa: 'شروع کن', price: 1500, assetPath: 'assets/stickers/set_2/sticker_20.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb21', category: StoreCategory.sticker, nameFa: 'خخخ', price: 1500, assetPath: 'assets/stickers/set_2/sticker_21.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb22', category: StoreCategory.sticker, nameFa: 'مطمئنم', price: 1500, assetPath: 'assets/stickers/set_2/sticker_22.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb23', category: StoreCategory.sticker, nameFa: 'هدف', price: 1500, assetPath: 'assets/stickers/set_2/sticker_23.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb24', category: StoreCategory.sticker, nameFa: 'تارگت شدی', price: 1500, assetPath: 'assets/stickers/set_2/sticker_24.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb25', category: StoreCategory.sticker, nameFa: 'بیا اینجا', price: 1500, assetPath: 'assets/stickers/set_2/sticker_25.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb26', category: StoreCategory.sticker, nameFa: 'شک دارم', price: 1500, assetPath: 'assets/stickers/set_2/sticker_26.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb27', category: StoreCategory.sticker, nameFa: 'بفرما', price: 1500, assetPath: 'assets/stickers/set_2/sticker_27.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb28', category: StoreCategory.sticker, nameFa: 'بازنشینی', price: 1500, assetPath: 'assets/stickers/set_2/sticker_28.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb29', category: StoreCategory.sticker, nameFa: 'بازی تمومه', price: 1500, assetPath: 'assets/stickers/set_2/sticker_29.png', currency: StoreCurrency.coins),
    StoreItem(id: 'sb30', category: StoreCategory.sticker, nameFa: 'افسانه‌ای', price: 1500, assetPath: 'assets/stickers/set_2/sticker_30.png', currency: StoreCurrency.coins),
  ];
  static final List<StoreItem> gifs = <StoreItem>[];
  static final List<StoreItem> tombstones = <StoreItem>[
    StoreItem(id: 'ts01', category: StoreCategory.tombstone, nameFa: 'رفتی… اما فراموش نمی‌شوی', price: 8000, assetPath: 'assets/tombstones/tomb_01.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts02', category: StoreCategory.tombstone, nameFa: 'یک نام، یک تاریخ', price: 9000, assetPath: 'assets/tombstones/tomb_02.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts03', category: StoreCategory.tombstone, nameFa: 'ما همیشه زنده‌ایم', price: 10000, assetPath: 'assets/tombstones/tomb_03.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts04', category: StoreCategory.tombstone, nameFa: 'سکوت سنگین‌تر از حرف‌هاست', price: 11000, assetPath: 'assets/tombstones/tomb_04.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts05', category: StoreCategory.tombstone, nameFa: 'گذشتگان همیشه زنده‌اند', price: 12000, assetPath: 'assets/tombstones/tomb_05.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts06', category: StoreCategory.tombstone, nameFa: 'حکایت ما ادامه دارد', price: 14000, assetPath: 'assets/tombstones/tomb_06.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts07', category: StoreCategory.tombstone, nameFa: 'پایان، فقط یک شروع است', price: 16000, assetPath: 'assets/tombstones/tomb_07.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts08', category: StoreCategory.tombstone, nameFa: 'وفاداری تا آخرین نفس', price: 18000, assetPath: 'assets/tombstones/tomb_08.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts09', category: StoreCategory.tombstone, nameFa: 'شیران هرگز نمی‌میرند', price: 20000, assetPath: 'assets/tombstones/tomb_09.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts10', category: StoreCategory.tombstone, nameFa: 'بازی تمام نشده', price: 22000, assetPath: 'assets/tombstones/tomb_10.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts11', category: StoreCategory.tombstone, nameFa: 'دل‌های بزرگ', price: 25000, assetPath: 'assets/tombstones/tomb_11.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts12', category: StoreCategory.tombstone, nameFa: 'مردان واقعی', price: 28000, assetPath: 'assets/tombstones/tomb_12.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts13', category: StoreCategory.tombstone, nameFa: 'خون، تعهد، مافیا', price: 31000, assetPath: 'assets/tombstones/tomb_13.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts14', category: StoreCategory.tombstone, nameFa: 'تا ابد در داستان', price: 34000, assetPath: 'assets/tombstones/tomb_14.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts15', category: StoreCategory.tombstone, nameFa: 'پادشاهان نمی‌میرند', price: 37000, assetPath: 'assets/tombstones/tomb_15.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts16', category: StoreCategory.tombstone, nameFa: 'یک افسانه برای همیشه', price: 40000, assetPath: 'assets/tombstones/tomb_16.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts17', category: StoreCategory.tombstone, nameFa: 'عشق، خیانت و مافیا', price: 43000, assetPath: 'assets/tombstones/tomb_17.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts18', category: StoreCategory.tombstone, nameFa: 'قدرت هرگز نمی‌میرد', price: 46000, assetPath: 'assets/tombstones/tomb_18.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts19', category: StoreCategory.tombstone, nameFa: 'داستان ما ادامه دارد', price: 48000, assetPath: 'assets/tombstones/tomb_19.png', currency: StoreCurrency.coins),
    StoreItem(id: 'ts20', category: StoreCategory.tombstone, nameFa: 'افسانه‌ها پایان ندارند', price: 50000, assetPath: 'assets/tombstones/tomb_20.png', currency: StoreCurrency.coins),
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
