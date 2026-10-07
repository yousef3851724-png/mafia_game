class AvatarCatalog {
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
