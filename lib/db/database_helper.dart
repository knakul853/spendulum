import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:spendulum/db/tables/accounts_table.dart';
import 'package:spendulum/db/tables/expense_table.dart';
import 'package:spendulum/db/tables/category_table.dart';
import 'package:spendulum/db/tables/budget_table.dart';
import 'package:spendulum/db/tables/incomes_table.dart';

/// A singleton class that manages the SQLite database for the Spendulum application.
/// It provides methods to initialize the database, create tables, and perform
/// CRUD operations on the database.
class DatabaseHelper {
  // Singleton instance of DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Private constructor to prevent instantiation from outside
  DatabaseHelper._init();

  /// Getter to access the database instance.
  /// If the database is not initialized, it will call the _initDB method to create it.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spendulum.db');
    return _database!;
  }

  /// Initializes the database by creating a new database file at the specified path.
  ///
  /// [filePath] - The name of the database file to be created.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // Get the default database path
    final path = join(dbPath, filePath); // Join the path with the file name

    // Open the database and create it if it doesn't exist
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Creates the necessary tables in the database when it is first created.
  ///
  /// [db] - The database instance where the tables will be created.
  /// [version] - The version of the database.
  Future<void> _createDB(Database db, int version) async {
    // Execute SQL commands to create tables
    await db.execute(AccountsTable.createTableQuery);
    await db.execute(ExpensesTable.createTableQuery);
    await db.execute(CategoriesTable.createTable);
    await db.execute(BudgetsTable.createTable);
    await db.execute(IncomesTable.createTableQuery);

    // Add other table creation queries here as needed
  }

  // Generic methods for database operations

  /// Inserts a new row into the specified table.
  ///
  /// [table] - The name of the table where the row will be inserted.
  /// [row] - A map containing the column names and their corresponding values.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database; // Get the database instance
    return await db.insert(table, row); // Insert the row and return the result
  }

  /// Queries all rows from the specified table.
  ///
  /// [table] - The name of the table to query.
  ///
  /// Returns a list of maps, where each map represents a row in the table.
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await instance.database; // Get the database instance
    return await db.query(table); // Query all rows and return the result
  }

  /// Executes a raw SQL query on the database.
  ///
  /// [sql] - The SQL query string to execute.
  /// [arguments] - Optional list of arguments for the SQL query.
  ///
  /// Returns a list of maps, where each map represents a row in the result set.

  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    final db = await instance.database;
    return await db.rawQuery(sql, arguments);
  }

  /// Updates a specific row in the specified table.
  ///
  /// [table] - The name of the table where the row will be updated.
  /// [row] - A map containing the updated column names and their corresponding values.
  /// [columnId] - The column name that will be used to identify the row to update.
  /// [value] - The value of the columnId to find the specific row.
  Future<int> update(String table, Map<String, dynamic> row, String columnId,
      dynamic value) async {
    final db = await instance.database; // Get the database instance
    return await db.update(table, row,
        where: '$columnId = ?',
        whereArgs: [value]); // Update the row and return the result
  }

  /// Executes a batch of database operations.
  ///
  /// [actions] - A function that takes a Batch object and defines the operations to be performed.
  ///
  /// This method creates a new batch, passes it to the provided function for operation definition,
  /// and then commits the batch without returning results.

  Future<void> batch(Function(Batch) actions) async {
    final db = await instance.database;
    final batch = db.batch();
    actions(batch);
    await batch.commit(noResult: true);
  }

  /// Deletes a specific row from the specified table.
  ///
  /// [table] - The name of the table where the row will be deleted.
  /// [columnId] - The column name that will be used to identify the row to delete.
  /// [value] - The value of the columnId to find the specific row.
  Future<int> delete(String table, String columnId, dynamic value) async {
    final db = await instance.database; // Get the database instance
    return await db.delete(table,
        where: '$columnId = ?',
        whereArgs: [value]); // Delete the row and return the result
  }
}
