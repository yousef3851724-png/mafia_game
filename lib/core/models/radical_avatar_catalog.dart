// ۷۰ آواتار رادیکال — set_70
class RadicalAvatarAsset {
  final String id;
  final String assetPath;
  final String displayNameFa;
  final bool isPremium;
  const RadicalAvatarAsset({
    required this.id,
    required this.assetPath,
    required this.displayNameFa,
    this.isPremium = false,
  });
}

class RadicalAvatarCatalog {
  static const List<RadicalAvatarAsset> avatars = <RadicalAvatarAsset>[
    RadicalAvatarAsset(id: 'a01', assetPath: 'assets/avatars/set_70/avatar_01.png', displayNameFa: 'آواتار 1'),
    RadicalAvatarAsset(id: 'a02', assetPath: 'assets/avatars/set_70/avatar_02.png', displayNameFa: 'آواتار 2'),
    RadicalAvatarAsset(id: 'a03', assetPath: 'assets/avatars/set_70/avatar_03.png', displayNameFa: 'آواتار 3'),
    RadicalAvatarAsset(id: 'a04', assetPath: 'assets/avatars/set_70/avatar_04.png', displayNameFa: 'آواتار 4'),
  ];

  static RadicalAvatarAsset? byId(String id) {
    for (final a in avatars) {
      if (a.id == id) return a;
    }
    return null;
  }

  static bool get isEmpty => avatars.isEmpty;
}
