import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spendly.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel Transaksi
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        categoryIcon TEXT NOT NULL,
        date INTEGER NOT NULL,
        mood TEXT NOT NULL,
        note TEXT,
        photoPath TEXT
      )
    ''');

    // Tabel Budget
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        categoryIcon TEXT NOT NULL,
        monthlyLimit REAL NOT NULL,
        currentSpent REAL DEFAULT 0
      )
    ''');

    // Tabel Savings Goal
    await db.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL DEFAULT 0,
        deadline INTEGER,
        isCompleted INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}