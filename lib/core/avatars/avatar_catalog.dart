class AvatarCatalog {
  static const int count = 100;
  static List<String> get all => List.generate(count, path);

  static String path(int index) {
    final n = (index + 1).toString().padLeft(3, '0');
    return 'assets/avatars_v2/avatar_$n.png';
  }
}
