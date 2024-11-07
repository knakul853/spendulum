import 'package:flutter/foundation.dart';
import 'package:spendulum/db/database_helper.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/models/export_job.dart';
import 'package:spendulum/db/tables/export_jobs_table.dart';
import 'package:spendulum/services/export_service.dart';

class ExportProvider with ChangeNotifier {
  final ExportService _exportService;
  List<ExportJob> _activeJobs = [];
  bool _isLoading = false;

  ExportProvider(this._exportService);

  List<ExportJob> get activeJobs => _activeJobs;
  bool get isLoading => _isLoading;

  Future<void> loadActiveJobs() async {
    try {
      _isLoading = true;
      notifyListeners();

      final jobs = await DatabaseHelper.instance.queryRows(
        ExportJobsTable.tableName,
        where: '${ExportJobsTable.columnStatus} IN (?, ?)',
        whereArgs: [
          ExportStatus.pending.toString(),
          ExportStatus.inProgress.toString(),
        ],
      );

      _activeJobs = jobs.map((job) => ExportJob.fromMap(job)).toList();
    } catch (e) {
      AppLogger.error('Error loading active export jobs', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createExportJob(ExportJob job) async {
    await _exportService.createExportJob(job);
    await loadActiveJobs();
  }
}
