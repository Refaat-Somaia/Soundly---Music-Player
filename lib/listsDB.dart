import 'package:sqflite/sqflite.dart';

class ListsDatabase {
  static final ListsDatabase instance = ListsDatabase._internal();

  static Database? _database;

  ListsDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/Listss.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }
    Future<void> _createDatabase(Database db, int version) async {
    return await db.execute('''
        CREATE TABLE lists (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          count INTEGER
        )
      ''');
  }
}