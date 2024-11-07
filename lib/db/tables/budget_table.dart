import 'package:spendulum/db/tables/accounts_table.dart';

class BudgetsTable {
  static const String tableName = 'budgets';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnAccountId = 'account_id';
  static const String columnCategoryId = 'category_id';
  static const String columnAmount = 'amount';
  static const String columnPeriod = 'period';
  static const String columnStartDate = 'start_date';
  static const String columnEndDate = 'end_date';
  static const String columnSpent = 'spent';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnAccountId TEXT NOT NULL,
      $columnCategoryId TEXT,
      $columnAmount REAL NOT NULL,
      $columnPeriod INTEGER NOT NULL,
      $columnStartDate TEXT NOT NULL,
      $columnEndDate TEXT NOT NULL,
      $columnSpent REAL NOT NULL DEFAULT 0.0,
      FOREIGN KEY ($columnAccountId) REFERENCES ${AccountsTable.tableName} (${AccountsTable.columnId})
    )
  ''';
}
