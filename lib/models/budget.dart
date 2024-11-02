/// Represents a budget for a specific account and period.
class Budget {
  final String id;
  final String name;
  final String accountId;
  final List<String> categories; // Changed to support multiple categories
  final double amount;
  final Period period;
  DateTime startDate;
  DateTime endDate;
  double spent;
  BudgetStatus status;
  final bool rollover; // New field to support rolling over unused amount
  double? rolledOverAmount; // Amount rolled over from previous period
  final String? notes; // Optional notes/description
  DateTime createdAt;
  DateTime updatedAt;

  Budget({
    required this.id,
    required this.name,
    required this.accountId,
    this.categories = const [], // Default to empty list
    required this.amount,
    required this.period,
    required this.startDate,
    DateTime? endDate,
    this.spent = 0.0,
    this.status = BudgetStatus.active,
    this.rollover = false,
    this.rolledOverAmount,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.endDate = endDate ?? _calculateEndDate(startDate, period),
        this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  double get remaining => (amount + (rolledOverAmount ?? 0)) - spent;

  double get progress =>
      (spent / (amount + (rolledOverAmount ?? 0))).clamp(0.0, 1.0);

  bool get isExceeded => spent > (amount + (rolledOverAmount ?? 0));

  void addExpense(double expenseAmount) {
    spent += expenseAmount;
    updateStatus();
  }

  void updateStatus() {
    if (isExceeded) {
      status = BudgetStatus.exceeded;
    } else if (DateTime.now().isAfter(endDate)) {
      status = BudgetStatus.completed;
    }
    updatedAt = DateTime.now();
  }

  void resetBudget() {
    double? newRolledAmount;
    if (rollover && remaining > 0) {
      newRolledAmount = remaining;
    }

    spent = 0.0;
    startDate = DateTime.now();
    endDate = _calculateEndDate(startDate, period);
    status = BudgetStatus.active;
    rolledOverAmount = newRolledAmount;
    updatedAt = DateTime.now();
  }

  static DateTime _calculateEndDate(DateTime start, Period period) {
    switch (period) {
      case Period.daily:
        return start.add(const Duration(days: 1));
      case Period.weekly:
        return start.add(const Duration(days: 7));
      case Period.biweekly:
        return start.add(const Duration(days: 14));
      case Period.monthly:
        return DateTime(start.year, start.month + 1, start.day);
      case Period.quarterly:
        return DateTime(start.year, start.month + 3, start.day);
      case Period.yearly:
        return DateTime(start.year + 1, start.month, start.day);
      case Period.custom:
        return start; // Should be set explicitly when period is custom
    }
  }
}

enum Period { daily, weekly, biweekly, monthly, quarterly, yearly, custom }

enum BudgetStatus { active, paused, completed, exceeded }
