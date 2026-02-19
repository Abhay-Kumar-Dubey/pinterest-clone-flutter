import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/saved_pin.dart';

class SavedPinsLocalDataSource {
  static Database? _database;
  static const String tableName = 'saved_pins';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pinterest_saved_pins.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imageUrl TEXT NOT NULL,
            photographer TEXT NOT NULL,
            aspectRatio REAL NOT NULL,
            originalIndex INTEGER NOT NULL,
            savedAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> savePin(SavedPin pin) async {
    final db = await database;

    final existing = await db.query(
      tableName,
      where: 'imageUrl = ?',
      whereArgs: [pin.imageUrl],
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return await db.insert(tableName, pin.toMap());
  }

  Future<List<SavedPin>> getAllSavedPins() async {
    final db = await database;
    final maps = await db.query(tableName, orderBy: 'savedAt DESC');

    return maps.map((map) => SavedPin.fromMap(map)).toList();
  }

  Future<bool> isPinSaved(String imageUrl) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'imageUrl = ?',
      whereArgs: [imageUrl],
    );

    return result.isNotEmpty;
  }

  Future<int> deletePin(String imageUrl) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'imageUrl = ?',
      whereArgs: [imageUrl],
    );
  }

  Future<void> clearAllPins() async {
    final db = await database;
    await db.delete(tableName);
  }
}
