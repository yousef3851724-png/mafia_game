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

  static final List<FramePng> all = List.generate(24, (i) {
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
}
