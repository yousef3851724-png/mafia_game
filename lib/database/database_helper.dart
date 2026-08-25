import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/player.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mafia_game.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE players (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      role TEXT NOT NULL
    )
    ''');
  }

  // ذخیره بازیکن در دیتابیس
  Future<void> insertPlayer(Player player) async {
    final db = await database;
    await db.insert('players', player.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // دریافت لیست بازیکنان از دیتابیس
  Future<List<Player>> getPlayers() async {
    final db = await database;
    final result = await db.query('players');
    return result.map((e) => Player.fromMap(e)).toList();
  }

  // پاک کردن همه بازیکنان
  Future<void> clearPlayers() async {
    final db = await database;
    await db.delete('players');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
