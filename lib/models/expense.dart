/// Represents a single expense record.
class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final String accountId;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.accountId,
  });
}
