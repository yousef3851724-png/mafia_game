import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mafia_game.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE game_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            players TEXT NOT NULL,
            winner TEXT NOT NULL,
            nights INTEGER NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveGameHistory({
    required List<String> players,
    required String winner,
    required int nights,
  }) async {
    final db = await database;
    await db.insert(
      'game_history',
      {
        'players': jsonEncode(players),
        'winner': winner,
        'nights': nights,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getGameHistory() async {
    final db = await database;
    return await db.query(
      'game_history',
      orderBy: 'timestamp DESC',
      limit: 50,
    );
  }
}
