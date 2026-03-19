import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // In-memory fallback for Flutter Web
  static final List<Expense> _webExpenses = [];
  static int _webIdCounter = 1;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // We do not actually initialize sqflite for web, we use our in-memory fallback logic
    if (kIsWeb) {
      throw UnsupportedError('sqflite database init should not be called on web');
    }
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE expenses ADD COLUMN description TEXT;');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT
)
''');
  }

  Future<Expense> create(Expense expense) async {
    if (kIsWeb) {
      final newExpense = Expense(
        id: _webIdCounter++,
        title: expense.title,
        amount: expense.amount,
        date: expense.date,
        category: expense.category,
        description: expense.description,
      );
      _webExpenses.add(newExpense);
      return newExpense;
    }

    final db = await instance.database;
    final id = await db.insert('expenses', expense.toMap());
    return Expense(
      id: id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      description: expense.description,
    );
  }

  Future<Expense> readExpense(int id) async {
    if (kIsWeb) {
      return _webExpenses.firstWhere(
        (e) => e.id == id, 
        orElse: () => throw Exception('ID $id not found')
      );
    }

    final db = await instance.database;
    final maps = await db.query(
      'expenses',
      columns: ['id', 'title', 'amount', 'date', 'category', 'description'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Expense>> readAllExpenses() async {
    if (kIsWeb) {
      final list = List<Expense>.from(_webExpenses);
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }

    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<int> update(Expense expense) async {
    if (kIsWeb) {
      final index = _webExpenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _webExpenses[index] = expense;
        return 1;
      }
      return 0;
    }

    final db = await instance.database;
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    if (kIsWeb) {
      _webExpenses.removeWhere((e) => e.id == id);
      return 1;
    }

    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    if (kIsWeb) {
      _webExpenses.clear();
      return;
    }

    final db = await instance.database;
    db.close();
  }
}
