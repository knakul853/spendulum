enum Period { weekly, monthly, yearly }

class Budget {
  final String id;
  final String name;
  final String accountId; // Mandatory
  final String? categoryId; // Optional
  final double amount;
  final Period period;
  DateTime startDate;
  DateTime endDate;
  double spent;

  Budget({
    required this.id,
    required this.name,
    required this.accountId,
    this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    DateTime? endDate,
    this.spent = 0.0,
  }) : this.endDate = endDate ?? _calculateEndDate(startDate, period);

  double get remaining => amount - spent;

  double get progress => (spent / amount).clamp(0.0, 1.0);

  bool isWithinPeriod(DateTime date) {
    return date.isAfter(startDate.subtract(Duration(days: 1))) &&
        date.isBefore(endDate.add(Duration(days: 1)));
  }

  void addExpense(double expenseAmount) {
    spent += expenseAmount;
  }

  void resetBudget() {
    spent = 0.0;
    startDate = DateTime.now();
    endDate = _calculateEndDate(startDate, period);
  }

  static DateTime _calculateEndDate(DateTime start, Period period) {
    switch (period) {
      case Period.weekly:
        return start.add(Duration(days: 7));
      case Period.monthly:
        return DateTime(start.year, start.month + 1, start.day);
      case Period.yearly:
        return DateTime(start.year + 1, start.month, start.day);
    }
  }
}
