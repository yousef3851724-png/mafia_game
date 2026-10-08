import re, shutil
SI = 'lib/features/store/store_items.dart'
AC = 'lib/core/avatars/avatar_catalog.dart'
PUB = 'pubspec.yaml'
si = open(SI, encoding='utf-8').read()
pub = open(PUB, encoding='utf-8').read()
if '_coinOverrides' in si or 'assets/tombstones/' in pub:
    print('NOT written - already patched'); raise SystemExit(1)

# 1) avatar catalog: 70 + 29 = 99, second batch lives in set_29
AC_NEW = """class AvatarCatalog {
  static const int count = 99;

  static List<String> get all => List.generate(count, path);

  static String path(int index) {
    if (index < 70) {
      final n = (index + 1).toString().padLeft(2, '0');
      return 'assets/avatars/set_70/avatar_$n.png';
    }
    final n = (index - 69).toString().padLeft(2, '0');
    return 'assets/avatars/set_29/avatar_$n.png';
  }
}
"""

# 2) coin prices for the avatars the owner picked (coins, not diamonds)
OVR = """  // price overrides in COINS (officers 3000, chef 4000, elders 5000, 22-24 cheap)
  static const Map<int, int> _coinOverrides = <int, int>{
    22: 500, 23: 500, 24: 500,
    15: 3000, 18: 3000, 19: 3500,
    49: 4000,
    13: 5000, 16: 5000, 20: 5000, 27: 5000, 39: 5000, 56: 5000, 70: 5000,
  };

"""
m = re.search(r"  static final List<StoreItem> avatars\s*=", si)
if not m: print('NOT written - avatars list not found'); raise SystemExit(1)
si2 = si[:m.start()] + OVR + si[m.start():]
si2, c1 = re.subn(r"price:\s*_avatarPrice\(i \+ 1\),", "price: _coinOverrides[i + 1] ?? _avatarPrice(i + 1),", si2, count=1)
si2, c2 = re.subn(r"currency:\s*_legendary\.contains\(i \+ 1\)\s*\?\s*StoreCurrency\.diamonds\s*:\s*StoreCurrency\.coins,",
    "currency: _coinOverrides.containsKey(i + 1)\n            ? StoreCurrency.coins\n            : (_legendary.contains(i + 1)\n                ? StoreCurrency.diamonds\n                : StoreCurrency.coins),", si2, count=1)

# 3) tombstones
T = [('01_classic','کلاسیک',300,'coins'),('02_cross','صلیب',500,'coins'),('03_obelisk','ستون',800,'coins'),
     ('04_gothic','گوتیک',1000,'coins'),('05_skull','جمجمه',1500,'coins'),('06_rose','رز',2000,'coins'),
     ('07_crown','تاج',3000,'coins'),('08_mafia','مافیا',3500,'coins'),('09_raven','کلاغ',4000,'coins'),
     ('10_moon','ماه',600,'diamonds'),('11_marble','مرمر',900,'diamonds'),('12_gold','طلایی',1500,'diamonds')]
rows = ''.join(f"    StoreItem(id: 'ts{k[:2]}', category: StoreCategory.tombstone, nameFa: '{n}', price: {p}, assetPath: 'assets/tombstones/tombstone_{k}.png', currency: StoreCurrency.{c}),\n" for k,n,p,c in T)
si2, c3 = re.subn(r"static final List<StoreItem> tombstones = <StoreItem>\[\];",
    lambda mm: "static final List<StoreItem> tombstones = <StoreItem>[\n" + rows + "  ];", si2, count=1)

pub2, c4 = re.subn(r"(\n(\s*)- assets/avatars/set_70/)", lambda mm: mm.group(1) + "\n" + mm.group(2) + "- assets/tombstones/", pub, count=1)
print('price', c1, '| currency', c2, '| tombstones', c3, '| pubspec', c4)
if (c1, c2, c3, c4) == (1, 1, 1, 1):
    for f in (SI, AC, PUB): shutil.copy(f, f + '.bak')
    open(SI, 'w', encoding='utf-8').write(si2)
    open(AC, 'w', encoding='utf-8').write(AC_NEW)
    open(PUB, 'w', encoding='utf-8').write(pub2)
    print('OK written (backups: .bak)')
else:
    print('NOT written - send this output')
