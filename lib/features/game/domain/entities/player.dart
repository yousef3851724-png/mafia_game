class Player {
  final String id;
  final String name;
  final String role;
  final bool isAlive;
  final int votesReceived;

  const Player({
    required this.id,
    required this.name,
    required this.role,
    this.isAlive = true,
    this.votesReceived = 0,
  });

  Player copyWith({
    String? id,
    String? name,
    String? role,
    bool? isAlive,
    int? votesReceived,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      votesReceived: votesReceived ?? this.votesReceived,
    );
  }
}
