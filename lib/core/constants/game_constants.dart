enum GameRole { mafia, citizen, doctor, detective }

class GameConstants {
  static const int minPlayers = 6;
  static const int maxPlayers = 30;
  static const int mafiaCount = 2;
  static const Duration nightDuration = Duration(seconds: 45);
  static const Duration dayDuration = Duration(minutes: 2);

  static String getRoleName(GameRole role) {
    switch (role) {
      case GameRole.mafia:
        return 'مافیا';
      case GameRole.citizen:
        return 'شهروند';
      case GameRole.doctor:
        return 'پزشک';
      case GameRole.detective:
        return 'کارآگاه';
    }
  }
}
