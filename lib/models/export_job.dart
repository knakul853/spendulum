import 'package:uuid/uuid.dart';

enum ExportType { csv, excel }

enum ExportStatus { pending, inProgress, completed, failed }

class ExportJob {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String email;
  final ExportType exportType;
  final DateTime createdAt;
  ExportStatus status;
  int retryCount;
  DateTime? lastRetryAt;
  String? errorMessage;

  ExportJob({
    String? id,
    required this.startDate,
    required this.endDate,
    required this.email,
    required this.exportType,
    this.status = ExportStatus.pending,
    this.retryCount = 0,
    this.lastRetryAt,
    this.errorMessage,
  })  : id = id ?? const Uuid().v4(),
        createdAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'email': email,
      'export_type': exportType.toString(),
      'status': status.toString(),
      'retry_count': retryCount,
      'last_retry_at': lastRetryAt?.toIso8601String(),
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExportJob.fromMap(Map<String, dynamic> map) {
    return ExportJob(
      id: map['id'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      email: map['email'],
      exportType: ExportType.values
          .firstWhere((e) => e.toString() == map['export_type']),
      status:
          ExportStatus.values.firstWhere((e) => e.toString() == map['status']),
      retryCount: map['retry_count'],
      lastRetryAt: map['last_retry_at'] != null
          ? DateTime.parse(map['last_retry_at'])
          : null,
      errorMessage: map['error_message'],
    );
  }
}
