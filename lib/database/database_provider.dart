import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/diary_entry.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  static Database? _database;

  factory DatabaseProvider() {
    return _instance;
  }

  DatabaseProvider._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'diary_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        imagePath TEXT,
        isReminderEnabled INTEGER NOT NULL,
        reminderType TEXT NOT NULL,
        reminderTime TEXT NOT NULL,
        content TEXT,
        createdAt TEXT NOT NULL
      )
      ''',
    );
  }

  // Create
  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert('diary_entries', entry.toMap());
  }

  // Read all
  Future<List<DiaryEntry>> getAllDiaryEntries() async {
    final db = await database;
    final maps = await db.query(
      'diary_entries',
      orderBy: 'dateTime DESC',
    );
    return List.generate(maps.length, (i) => DiaryEntry.fromMap(maps[i]));
  }

  // Read by ID
  Future<DiaryEntry?> getDiaryEntry(int id) async {
    final db = await database;
    final maps = await db.query(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return DiaryEntry.fromMap(maps.first);
    }
    return null;
  }

  // Update
  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // Delete
  Future<int> deleteDiaryEntry(int id) async {
    final db = await database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search
  Future<List<DiaryEntry>> searchDiaryEntries(String query) async {
    final db = await database;
    final maps = await db.query(
      'diary_entries',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'dateTime DESC',
    );
    return List.generate(maps.length, (i) => DiaryEntry.fromMap(maps[i]));
  }
}
