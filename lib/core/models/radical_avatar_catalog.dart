// کاتالوگ آواتار — خالی. پرتره‌های واقعی بعداً اضافه می‌شوند.
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
  static const List<RadicalAvatarAsset> avatars = <RadicalAvatarAsset>[];
  static RadicalAvatarAsset? byId(String id) {
    for (final a in avatars) { if (a.id == id) return a; }
    return null;
  }
  static bool get isEmpty => avatars.isEmpty;
}
