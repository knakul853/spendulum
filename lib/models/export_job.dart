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
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'email': email,
      'exportType': exportType.toString(),
      'status': status.toString(),
      'retryCount': retryCount,
      'lastRetryAt': lastRetryAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExportJob.fromMap(Map<String, dynamic> map) {
    return ExportJob(
      id: map['id'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      email: map['email'],
      exportType: ExportType.values
          .firstWhere((e) => e.toString() == map['exportType']),
      status:
          ExportStatus.values.firstWhere((e) => e.toString() == map['status']),
      retryCount: map['retryCount'],
      lastRetryAt: map['lastRetryAt'] != null
          ? DateTime.parse(map['lastRetryAt'])
          : null,
      errorMessage: map['errorMessage'],
    );
  }
}
