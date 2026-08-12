class Player {
  final String id;
  final String name;
  Role role;
  bool isAlive;
  bool isProtected;
  final bool isAI; // ← برای تشخیص بازیکن واقعی از ربات

  Player({
    required this.id,
    required this.name,
    required this.role,
    this.isAlive = true,
    this.isProtected = false,
    this.isAI = false,
  });
}
