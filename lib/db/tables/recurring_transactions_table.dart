import 'package:spendulum/db/tables/accounts_table.dart';

class RecurringTransactionsTable {
  static const String tableName = 'recurring_transactions';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnAmount = 'amount';
  static const String columnAccountId = 'account_id';
  static const String columnCategoryOrSource = 'category_or_source';
  static const String columnDescription = 'description';
  static const String columnFrequency = 'frequency';
  static const String columnStartDate = 'start_date';
  static const String columnEndDate = 'end_date';
  static const String columnReminderTime = 'reminder_time';
  static const String columnIsExpense = 'is_expense';
  static const String columnCustomDays = 'custom_days';
  static const String columnIsActive = 'is_active';
  static const String columnLastProcessed = 'last_processed';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnAmount REAL NOT NULL,
      $columnAccountId TEXT NOT NULL,
      $columnCategoryOrSource TEXT NOT NULL,
      $columnDescription TEXT,
      $columnFrequency TEXT NOT NULL,
      $columnStartDate TEXT NOT NULL,
      $columnEndDate TEXT,
      $columnReminderTime TEXT,
      $columnIsExpense INTEGER NOT NULL,
      $columnCustomDays INTEGER,
      $columnIsActive INTEGER NOT NULL DEFAULT 1,
      $columnLastProcessed TEXT,
      FOREIGN KEY ($columnAccountId) REFERENCES ${AccountsTable.tableName} (${AccountsTable.columnId})
    )
  ''';
}
