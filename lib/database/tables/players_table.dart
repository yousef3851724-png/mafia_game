/// اسکیمای جدول بازیکنان (پروفایل ثابت بازیکنان بین بازی‌های مختلف)
class PlayersTable {
  PlayersTable._();

  static const String tableName = 'players';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnAvatarPath = 'avatar_path';
  static const String columnGamesPlayed = 'games_played';
  static const String columnGamesWon = 'games_won';
  static const String columnCreatedAt = 'created_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnAvatarPath TEXT,
      $columnGamesPlayed INTEGER NOT NULL DEFAULT 0,
      $columnGamesWon INTEGER NOT NULL DEFAULT 0,
      $columnCreatedAt TEXT NOT NULL
    )
  ''';
}
