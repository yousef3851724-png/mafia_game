class Player {
  final String id;
  final String name;
  final String role;

  Player({required this.id, required this.name, required this.role});

  // تبدیل به Map برای ذخیره در دیتابیس
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }

  // ساخت بازیکن از Map (بازیابی از دیتابیس)
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
    );
  }
}
