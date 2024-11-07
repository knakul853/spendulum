import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;

  const MonthSelector({
    Key? key,
    required this.selectedMonth,
    required this.onMonthChanged,
  }) : super(key: key);

  // Function to get color based on month index

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors
                .grey[200], // Background color for the entire dropdown list
          ),
          child: DropdownButton<DateTime>(
            value: DateTime(selectedMonth.year, selectedMonth.month),
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 8,
            style: TextStyle(color: Colors.black, fontSize: 16),
            underline: Container(height: 0),
            isDense: true,
            hint: Text('Select Month'),
            onChanged: (DateTime? newValue) {
              if (newValue != null) {
                onMonthChanged(newValue);
              }
            },
            items: List.generate(12, (index) {
              final date = DateTime(selectedMonth.year, index + 1);
              return DropdownMenuItem<DateTime>(
                value: date,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('MMMM').format(date),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
