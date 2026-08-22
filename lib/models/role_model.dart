enum Role {
  mafia,
  citizen,
  doctor,
  detective,
  joker,
}

class RoleModel {
  final Role role;
  final String name;
  final String emoji;
  final String description;
  final bool isMafia;
  final bool hasNightAction;

  RoleModel({
    required this.role,
    required this.name,
    required this.emoji,
    required this.description,
    this.isMafia = false,
    this.hasNightAction = false,
  });

  factory RoleModel.fromRole(Role role) {
    switch (role) {
      case Role.mafia:
        return RoleModel(
          role: role,
          name: 'مافیا',
          emoji: '🔪',
          description: 'هر شب یک شهروند را می‌کشد.',
          isMafia: true,
          hasNightAction: true,
        );
      case Role.citizen:
        return RoleModel(
          role: role,
          name: 'شهروند',
          emoji: '👤',
          description: 'در روز رأی می‌دهد و شب را می‌خوابد.',
        );
      case Role.doctor:
        return RoleModel(
          role: role,
          name: 'دکتر',
          emoji: '💉',
          description: 'هر شب یک نفر را نجات می‌دهد.',
          hasNightAction: true,
        );
      case Role.detective:
        return RoleModel(
          role: role,
          name: 'کارآگاه',
          emoji: '🔍',
          description: 'هر شب نقش یک نفر را بررسی می‌کند.',
          hasNightAction: true,
        );
      case Role.joker:
        return RoleModel(
          role: role,
          name: 'دلقک',
          emoji: '🤡',
          description: 'اگر رأی بیاورد، بازی را می‌برد!',
        );
    }
  }
}
