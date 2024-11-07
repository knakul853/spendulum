import 'package:spendulum/ui/widgets/logger.dart';

/// Represents a single income record.
class Income {
  final String id;
  final String source;
  final double amount;
  final DateTime date;
  final String description;
  final String accountId;

  Income({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    required this.description,
    required this.accountId,
  }) {
    AppLogger.info('Income: Created new income object with ID: $id');
  }
}
