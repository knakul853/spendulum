import 'package:spendulum/ui/widgets/logger.dart';

class IncomesTable {
  static const String tableName = 'incomes';
  static const String columnId = 'id';
  static const String columnSource = 'source';
  static const String columnAmount = 'amount';
  static const String columnDate = 'date';
  static const String columnDescription = 'description';
  static const String columnAccountId = 'account_id';

  static String createTable() {
    AppLogger.info('IncomesTable: Creating table schema');
    return '''
      CREATE TABLE $tableName (
        $columnId TEXT PRIMARY KEY,
        $columnSource TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnDescription TEXT,
        $columnAccountId TEXT NOT NULL,
        FOREIGN KEY ($columnAccountId) REFERENCES accounts (id)
      )
    ''';
  }
}
