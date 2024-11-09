import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:spendulum/db/database_helper.dart';
import 'package:spendulum/models/export_job.dart';
import 'package:spendulum/db/tables/export_jobs_table.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/models/expense.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/config/env_config.dart';

class ExportService {
  final DatabaseHelper _db;
  final ExpenseProvider _expenseProvider;
  final AccountProvider _accountProvider;

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(minutes: 15);

  ExportService(this._db, this._expenseProvider, this._accountProvider);

  String _getAccountNumber(String accountId) {
    final account = _accountProvider.getAccountById(accountId);
    return account?.accountNumber ?? 'Unknown Account';
  }

  String _getAccountName(String accountId) {
    final account = _accountProvider.getAccountById(accountId);
    return account?.name ?? 'Unknown Account';
  }

  Future<void> createExportJob(ExportJob job) async {
    try {
      await _db.insert(ExportJobsTable.tableName, job.toMap());
      AppLogger.info('Created export job: ${job.id}');
      // Start processing the job
      unawaited(processJob(job));
    } catch (e) {
      AppLogger.error('Error creating export job', error: e);
      throw Exception('Failed to create export job');
    }
  }

  Future<List<Expense>> _getExpensesForExport(
      String accountId, DateTime startDate, DateTime endDate) async {
    if (accountId.toLowerCase() == 'all') {
      return await _expenseProvider.getExpensesForAccountAndDateRange(
        'all',
        startDate,
        endDate,
      );
    }

    return await _expenseProvider.getExpensesForAccountAndDateRange(
      accountId,
      startDate,
      endDate,
    );
  }

  Future<void> processJob(ExportJob job) async {
    try {
      // Update job status to in progress
      job.status = ExportStatus.inProgress;
      await _updateJobStatus(job);

      // Get expenses for the date range
      // Get expenses for the date range
      final expenses = await _getExpensesForExport(
        //job.accountId, : TODO: Support account filtering
        'all',
        job.startDate,
        job.endDate,
      );

      // Generate the export file
      final file = await _generateExportFile(expenses, job.exportType);

      await _sendExportEmail(job.email, file);

      // Update job status to completed
      job.status = ExportStatus.completed;
      await _updateJobStatus(job);

      // Clean up the temporary file
      await file.delete();
    } catch (e) {
      AppLogger.error('Error processing export job', error: e);
      await _handleExportError(job, e);
    }
  }

  Future<File> _generateExportFile(
      List<Expense> expenses, ExportType type) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename =
        'expense_export_$timestamp.${type == ExportType.csv ? 'csv' : 'xlsx'}';
    final file = File('${dir.path}/$filename');

    if (type == ExportType.csv) {
      return _generateCsvFile(expenses, file);
    } else {
      return _generateExcelFile(expenses, file);
    }
  }

  Future<File> _generateCsvFile(List<Expense> expenses, File file) async {
    final List<List<dynamic>> rows = [
      [
        'Date',
        'Category',
        'Amount',
        'Description',
        'Account Name',
        'Account Number'
      ]
    ];

    for (var expense in expenses) {
      rows.add([
        expense.date.toIso8601String(),
        expense.category,
        expense.amount,
        expense.description,
        _getAccountName(expense.accountId),
        _getAccountNumber(expense.accountId),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
    return file;
  }

  Future<File> _generateExcelFile(List<Expense> expenses, File file) async {
    final workbook = excel.Excel.createExcel();
    final sheet = workbook.sheets[workbook.getDefaultSheet()] ??
        workbook.sheets['Sheet1'];

    if (sheet == null) {
      throw Exception("Unable to create or access default sheet in workbook");
    }

    // Add headers with account information
    final headers = [
      'Date',
      'Category',
      'Amount',
      'Description',
      'Account Name',
      'Account Number'
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = headers[i]
        ..cellStyle = excel.CellStyle(
          bold: true,
          horizontalAlign: excel.HorizontalAlign.Center,
        );
    }

    // Add data with account information
    for (var i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      final row = i + 1;

      sheet
          .cell(excel.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = expense.date.toIso8601String();
      sheet
          .cell(excel.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        ..value = expense.category;
      sheet
          .cell(excel.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        ..value = expense.amount;
      sheet
          .cell(excel.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        ..value = expense.description;
      sheet
          .cell(excel.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        ..value = _getAccountName(expense.accountId);
      sheet
          .cell(excel.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        ..value = _getAccountNumber(expense.accountId);
    }

    await file.writeAsBytes(workbook.encode()!);
    return file;
  }

  Future<void> _sendExportEmail(String email, File file) async {
    final smtpEmail = await SecureConfig.getSecureValue('SMTP_EMAIL');
    final smtpPassword = await SecureConfig.getSecureValue('SMTP_PASSWORD');

    print("The SMTP email is $smtpEmail");
    print("The SMTP password is $smtpPassword");

    if (smtpEmail == null || smtpPassword == null) {
      throw Exception('SMTP credentials not configured');
    }

    final smtpServer = gmail(smtpEmail, smtpPassword);

    AppLogger.info('Sending export email to $email');

    final message = Message()
      ..from = Address(smtpEmail, 'Expense Tracker')
      ..recipients.add(email)
      ..subject = 'Your Expense Export'
      ..text = 'Please find your requested expense export attached.'
      ..attachments = [
        FileAttachment(file)
          ..location = Location.attachment
          ..fileName = file.path.split('/').last
      ];

    try {
      // Add timeout
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());

      AppLogger.info('Export email sent successfully to $email');
    } catch (e) {
      if (e is SocketException) {
        AppLogger.error('Network error while sending email: ${e.message}');
        throw Exception('Network error: Please check your internet connection');
      } else if (e is TimeoutException) {
        AppLogger.error('Email sending timed out');
        throw Exception('Email sending timed out: Please try again');
      } else {
        AppLogger.error('Error sending export email', error: e);
        throw Exception('Failed to send export email: ${e.toString()}');
      }
    }
  }

  Future<void> _handleExportError(ExportJob job, dynamic error) async {
    job.retryCount++;
    job.lastRetryAt = DateTime.now();
    job.errorMessage = error.toString();

    if (job.retryCount < maxRetries) {
      job.status = ExportStatus.pending;
      await _updateJobStatus(job);

      // Schedule retry with exponential backoff
      final delay = retryDelay * (1 << (job.retryCount - 1));
      Timer(delay, () => processJob(job));
    } else {
      job.status = ExportStatus.failed;
      await _updateJobStatus(job);
      AppLogger.error('Export job failed after max retries', error: error);
    }
  }

  Future<void> _updateJobStatus(ExportJob job) async {
    await _db.updateRows(
      ExportJobsTable.tableName,
      job.toMap(),
      where: '${ExportJobsTable.columnId} = ?',
      whereArgs: [job.id],
    );
  }

  Future<void> retryFailedJobs() async {
    try {
      final failedJobs = await _db.queryRows(
        ExportJobsTable.tableName,
        where: '${ExportJobsTable.columnStatus} = ?',
        whereArgs: [ExportStatus.failed.toString()],
      );

      for (final jobMap in failedJobs) {
        final job = ExportJob.fromMap(jobMap);
        job.status = ExportStatus.pending;
        job.retryCount = 0;
        await _updateJobStatus(job);
        unawaited(processJob(job));
      }
    } catch (e) {
      AppLogger.error('Error retrying failed jobs', error: e);
    }
  }
}
