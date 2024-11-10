import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/models/recurring_transaction.dart';

class RecurringSettingsModal extends StatefulWidget {
  final bool isExpense;
  final Function(RecurringTransaction) onSave;
  final RecurringTransaction? existingTransaction;

  const RecurringSettingsModal({
    Key? key,
    required this.isExpense,
    required this.onSave,
    this.existingTransaction,
  }) : super(key: key);

  @override
  _RecurringSettingsModalState createState() => _RecurringSettingsModalState();
}

class _RecurringSettingsModalState extends State<RecurringSettingsModal> {
  late RecurringFrequency _frequency;
  DateTime? _endDate;
  TimeOfDay? _reminderTime;
  int? _customDays;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _frequency =
        widget.existingTransaction?.frequency ?? RecurringFrequency.monthly;
    _endDate = widget.existingTransaction?.endDate;
    _reminderTime = widget.existingTransaction?.reminderTime;
    _customDays = widget.existingTransaction?.customDays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recurring Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFrequencyDropdown(),
            if (_frequency == RecurringFrequency.custom)
              _buildCustomDaysField(),
            const SizedBox(height: 16),
            _buildEndDatePicker(),
            const SizedBox(height: 16),
            _buildReminderTimePicker(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<RecurringFrequency>(
      value: _frequency,
      decoration: InputDecoration(
        labelText: 'Frequency',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: RecurringFrequency.values.map((frequency) {
        return DropdownMenuItem(
          value: frequency,
          child: Text(frequency.toString().split('.').last.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _frequency = value!;
        });
      },
    );
  }

  Widget _buildCustomDaysField() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        initialValue: _customDays?.toString(),
        decoration: InputDecoration(
          labelText: 'Repeat every X days',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter days';
          final days = int.tryParse(value);
          if (days == null || days < 1) return 'Please enter a valid number';
          return null;
        },
        onSaved: (value) {
          _customDays = int.tryParse(value ?? '');
        },
      ),
    );
  }

  Widget _buildEndDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate:
              _endDate ?? DateTime.now().add(const Duration(days: 365)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (picked != null) {
          setState(() {
            _endDate = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'End Date (Optional)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_endDate == null
                ? 'No end date'
                : DateFormat.yMMMd().format(_endDate!)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTimePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _reminderTime ?? TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() {
            _reminderTime = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Reminder Time (Optional)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_reminderTime == null
                ? 'No reminder'
                : _reminderTime!.format(context)),
            const Icon(Icons.access_time),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveSettings,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final transaction = RecurringTransaction(
        id: widget.existingTransaction?.id ?? DateTime.now().toString(),
        title: widget.existingTransaction?.title ?? '',
        amount: widget.existingTransaction?.amount ?? 0,
        accountId: widget.existingTransaction?.accountId ?? '',
        categoryOrSource: widget.existingTransaction?.categoryOrSource ?? '',
        description: widget.existingTransaction?.description ?? '',
        frequency: _frequency,
        startDate: DateTime.now(),
        endDate: _endDate,
        reminderTime: _reminderTime,
        isExpense: widget.isExpense,
        customDays: _customDays,
      );

      widget.onSave(transaction);
      Navigator.pop(context);
    }
  }
}
