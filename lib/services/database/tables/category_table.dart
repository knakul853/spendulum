class CategoriesTable {
  static const String tableName = 'categories';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnColor = 'color';
  static const String columnIcon = 'icon';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnColor TEXT NOT NULL,
      $columnIcon INTEGER NOT NULL
    )
  ''';
}
