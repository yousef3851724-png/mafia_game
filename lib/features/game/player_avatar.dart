class PlayerAvatar {
  final String id;
  final String displayName;
  final String? assetPath;
  final String? imageUrl;
  final bool female;
  final int seed;

  const PlayerAvatar({
    required this.id,
    required this.displayName,
    required this.assetPath,
    required this.imageUrl,
    required this.female,
    required this.seed,
  });

  PlayerAvatar copyWith({
    String? assetPath,
    String? imageUrl,
  }) => PlayerAvatar(
        id: id,
        displayName: displayName,
        assetPath: assetPath ?? this.assetPath,
        imageUrl: imageUrl ?? this.imageUrl,
        female: female,
        seed: seed,
      );
}
