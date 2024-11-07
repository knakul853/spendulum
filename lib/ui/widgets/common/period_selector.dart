import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function()? onDateRangeSelect;
  final bool showDateRange;

  const PeriodSelector({
    Key? key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.startDate,
    this.endDate,
    this.onDateRangeSelect,
    this.showDateRange = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Weekly', label: Text('Weekly')),
            ButtonSegment(value: 'Monthly', label: Text('Monthly')),
            ButtonSegment(value: 'Yearly', label: Text('Yearly')),
          ],
          selected: {selectedPeriod},
          onSelectionChanged: (Set<String> newSelection) {
            onPeriodChanged(newSelection.first);
          },
        ),
        if (showDateRange && startDate != null && endDate != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onDateRangeSelect,
            child: Text(
              '${DateFormat('MMM d, y').format(startDate!)} - ${DateFormat('MMM d, y').format(endDate!)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ],
    );
  }
}
