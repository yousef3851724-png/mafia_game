class AvatarCatalog {
  static const int count = 70;

  static List<String> get all => List.generate(count, path);

  static String path(int index) {
    final n = (index + 1).toString().padLeft(2, '0');
    return 'assets/avatars/set_70/avatar_$n.png';
  }
}
