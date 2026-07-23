import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/exceptions.dart';
import '../logger/app_logger.dart';
import 'tables/games_table.dart';
import 'tables/players_table.dart';

/// نقطه واحد دسترسی به دیتابیس محلی (Singleton)
class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docsDir.path, AppConstants.dbName);

      return await openDatabase(
        dbPath,
        version: AppConstants.dbVersion,
        onCreate: (db, version) async {
          await db.execute(PlayersTable.createTableQuery);
          await db.execute(GamesTable.createTableQuery);
          AppLogger.i('دیتابیس با موفقیت ساخته شد (v$version)');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          AppLogger.i('ارتقای دیتابیس از $oldVersion به $newVersion');
          // Migration های آینده اینجا اضافه می‌شوند
        },
      );
    } catch (e, st) {
      AppLogger.e('خطا در راه‌اندازی دیتابیس', e, st);
      throw DatabaseException('امکان راه‌اندازی دیتابیس وجود نداشت');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
