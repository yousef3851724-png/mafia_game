/// اسکیمای جدول تاریخچه بازی‌ها
class GamesTable {
  GamesTable._();

  static const String tableName = 'games';

  static const String columnId = 'id';
  static const String columnPlayedAt = 'played_at';
  static const String columnPlayerCount = 'player_count';
  static const String columnWinnerFaction = 'winner_faction';
  static const String columnDurationSeconds = 'duration_seconds';
  static const String columnPlayersJson = 'players_json';
  static const String columnNotes = 'notes';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnPlayedAt TEXT NOT NULL,
      $columnPlayerCount INTEGER NOT NULL,
      $columnWinnerFaction TEXT NOT NULL,
      $columnDurationSeconds INTEGER NOT NULL DEFAULT 0,
      $columnPlayersJson TEXT NOT NULL,
      $columnNotes TEXT
    )
  ''';
}
