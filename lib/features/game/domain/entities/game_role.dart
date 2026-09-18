import 'package:equatable/equatable.dart';

enum Faction { citizens, mafia, neutral }

enum GameRole { citizen, mafia, detective, doctor }

extension GameRoleX on GameRole {
  Faction get team {
    switch (this) {
      case GameRole.mafia:
        return Faction.mafia;
      case GameRole.citizen:
      case GameRole.detective:
      case GameRole.doctor:
        return Faction.citizens;
    }
  }

  String get title {
    switch (this) {
      case GameRole.citizen:
        return 'شهروند';
      case GameRole.mafia:
        return 'مافیا';
      case GameRole.detective:
        return 'کارآگاه';
      case GameRole.doctor:
        return 'دکتر';
    }
  }
}

class AssignedRole extends Equatable {
  final String playerId;
  final GameRole role;

  const AssignedRole({required this.playerId, required this.role});

  @override
  List<Object?> get props => [playerId, role];
}
