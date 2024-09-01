class AccountsTable {
  static const String tableName = 'accounts';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnAccountNumber = 'accountNumber';
  static const String columnAccountType = 'accountType';
  static const String columnBalance = 'balance';
  static const String columnColor = 'color';
  static const String columnCurrency = 'currency';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt'; // New column

  static const String createTableQuery = '''
    CREATE TABLE $tableName(
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnAccountNumber TEXT NOT NULL,
      $columnAccountType TEXT NOT NULL,
      $columnBalance REAL NOT NULL,
      $columnColor INTEGER NOT NULL,
      $columnCurrency TEXT NOT NULL,
      $columnCreatedAt INTEGER NOT NULL,
      $columnUpdatedAt INTEGER NOT NULL
    )
  ''';
}
