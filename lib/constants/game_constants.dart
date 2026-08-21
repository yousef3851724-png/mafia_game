enum PlayerRole {
  mafia,
  citizen,
  doctor,
  detective,
  none,
}

class GameConstants {
  static const int minPlayers = 6;
  static const int maxPlayers = 20;
  static const int defaultNightDuration = 30;
  static const int defaultDayDuration = 60;
}
class AppConstants {
  static const String appName = 'Mafia Radical';
  static const String version = '1.0.0';
}
