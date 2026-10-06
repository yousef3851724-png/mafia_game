import 'radical_frame_tier.dart';

class FramePng {
  final String id;
  final String assetPath;
  final String nameFa;
  final RadicalFrameTier tier;
  final int price;
  const FramePng({
    required this.id,
    required this.assetPath,
    required this.nameFa,
    required this.tier,
    required this.price,
  });
}

class FrameCatalogPng {
  static const _tiers = [
    RadicalFrameTier.bronze,
    RadicalFrameTier.silver,
    RadicalFrameTier.gold,
    RadicalFrameTier.platinum,
    RadicalFrameTier.diamond,
    RadicalFrameTier.legendary,
  ];
  static const _prices = [100, 250, 500, 900, 1400, 2000];

  static final List<FramePng> _base = List.generate(24, (i) {
    final n = (i + 1).toString().padLeft(2, '0');
    final t = i ~/ 4;
    return FramePng(
      id: 'f$n',
      assetPath: 'assets/frames/set_24/frame_$n.png',
      nameFa: 'فریم ${i + 1}',
      tier: _tiers[t],
      price: _prices[t],
    );
  });

  // 11 oval premium frames (set_oval)
  static final List<FramePng> _extra = <FramePng>[
    FramePng(id: 'f25', assetPath: 'assets/frames/set_oval/frame_01_frozen.png', nameFa: 'فروزن', tier: RadicalFrameTier.platinum, price: 2300),
    FramePng(id: 'f26', assetPath: 'assets/frames/set_oval/frame_02_hellfire.png', nameFa: 'هل فایر', tier: RadicalFrameTier.diamond, price: 2500),
    FramePng(id: 'f27', assetPath: 'assets/frames/set_oval/frame_03_kingcrown.png', nameFa: 'کینگ کراون', tier: RadicalFrameTier.diamond, price: 3000),
    FramePng(id: 'f28', assetPath: 'assets/frames/set_oval/frame_04_diamondcrystal.png', nameFa: 'دایموند کریستال', tier: RadicalFrameTier.platinum, price: 2200),
    FramePng(id: 'f29', assetPath: 'assets/frames/set_oval/frame_05_imperialgold.png', nameFa: 'امپریال گلد', tier: RadicalFrameTier.platinum, price: 2000),
    FramePng(id: 'f30', assetPath: 'assets/frames/set_oval/frame_06_mythic.png', nameFa: 'میتیک', tier: RadicalFrameTier.legendary, price: 8000),
    FramePng(id: 'f31', assetPath: 'assets/frames/set_oval/frame_07_wolf.png', nameFa: 'سردیس گرگ', tier: RadicalFrameTier.diamond, price: 3800),
    FramePng(id: 'f32', assetPath: 'assets/frames/set_oval/frame_08_demon.png', nameFa: 'دیمون', tier: RadicalFrameTier.diamond, price: 4500),
    FramePng(id: 'f33', assetPath: 'assets/frames/set_oval/frame_09_dragon.png', nameFa: 'دراگون', tier: RadicalFrameTier.legendary, price: 5000),
    FramePng(id: 'f34', assetPath: 'assets/frames/set_oval/frame_10_galaxy.png', nameFa: 'گلکسی', tier: RadicalFrameTier.diamond, price: 3500),
    FramePng(id: 'f35', assetPath: 'assets/frames/set_oval/frame_11_thunder.png', nameFa: 'تندر', tier: RadicalFrameTier.platinum, price: 2600),
  ];

  static final List<FramePng> all = <FramePng>[..._base, ..._extra];
}
