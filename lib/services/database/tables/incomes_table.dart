import 'package:spendulum/services/database/tables/accounts_table.dart';

class IncomesTable {
  static const String tableName = 'incomes';
  static const String columnId = 'id';
  static const String columnSource = 'source';
  static const String columnAmount = 'amount';
  static const String columnDate = 'date';
  static const String columnDescription = 'description';
  static const String columnAccountId = 'account_id';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnSource TEXT NOT NULL,
      $columnAmount REAL NOT NULL,
      $columnDate TEXT NOT NULL,
      $columnDescription TEXT,
      $columnAccountId TEXT NOT NULL,
      FOREIGN KEY ($columnAccountId) REFERENCES ${AccountsTable.tableName} (${AccountsTable.columnId})
    )
  ''';
}
