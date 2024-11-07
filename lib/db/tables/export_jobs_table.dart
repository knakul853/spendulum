class ExportJobsTable {
  static const String tableName = 'export_jobs';
  static const String columnId = 'id';
  static const String columnStartDate = 'start_date';
  static const String columnEndDate = 'end_date';
  static const String columnEmail = 'email';
  static const String columnExportType = 'export_type';
  static const String columnStatus = 'status';
  static const String columnRetryCount = 'retry_count';
  static const String columnLastRetryAt = 'last_retry_at';
  static const String columnErrorMessage = 'error_message';
  static const String columnCreatedAt = 'created_at';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnStartDate TEXT NOT NULL,
      $columnEndDate TEXT NOT NULL,
      $columnEmail TEXT NOT NULL,
      $columnExportType TEXT NOT NULL,
      $columnStatus TEXT NOT NULL,
      $columnRetryCount INTEGER NOT NULL,
      $columnLastRetryAt TEXT,
      $columnErrorMessage TEXT,
      $columnCreatedAt TEXT NOT NULL
    )
  ''';
}
