import 'package:spendulum/services/database/tables/accounts_table.dart';

class ExpensesTable {
  static const String tableName = 'expenses';
  static const String columnId = 'id';
  static const String columnCategory = 'category';
  static const String columnAmount = 'amount';
  static const String columnDate = 'date';
  static const String columnDescription = 'description';
  static const String columnAccountId = 'accountId';

  static const String createTableQuery = '''
    CREATE TABLE $tableName(
      $columnId TEXT PRIMARY KEY,
      $columnCategory TEXT NOT NULL,
      $columnAmount REAL NOT NULL,
      $columnDate TEXT NOT NULL,
      $columnDescription TEXT NOT NULL,
      $columnAccountId TEXT NOT NULL,
      FOREIGN KEY ($columnAccountId) REFERENCES ${AccountsTable.tableName} (${AccountsTable.columnId})
    )
  ''';
}
