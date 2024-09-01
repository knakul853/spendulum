import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:spendulum/services/database/tables/accounts_table.dart';
import 'package:spendulum/services/database/tables/expense_table.dart';
import 'package:spendulum/services/database/tables/category_table.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spendulum.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(AccountsTable.createTableQuery);
    await db.execute(ExpensesTable.createTableQuery);
    await db.execute(CategoriesTable.createTable);

    // Add other table creation queries here as needed
  }

  // Generic methods for database operations

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> row, String columnId,
      dynamic value) async {
    final db = await instance.database;
    return await db
        .update(table, row, where: '$columnId = ?', whereArgs: [value]);
  }

  Future<int> delete(String table, String columnId, dynamic value) async {
    final db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [value]);
  }
}
