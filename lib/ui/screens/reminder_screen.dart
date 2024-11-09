import 'package:flutter/material.dart';
import 'package:spendulum/services/reminder_service.dart';
import 'package:spendulum/models/reminder.dart';
import 'package:spendulum/providers/reminder_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final ReminderService _reminderService = ReminderService();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<int> _selectedDays = [];
  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeSelector(),
                const SizedBox(height: 16),
                _buildDaySelector(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedDays.isEmpty ? null : _saveReminder,
                    child: const Text('Add Reminder'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Scheduled Reminders'),
                TextButton(
                  onPressed: _showStopAllRemindersDialog,
                  child: const Text('Stop All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ReminderProvider>(
              builder: (context, provider, child) {
                final reminders = provider.reminders;
                if (reminders.isEmpty) {
                  return const Center(
                    child: Text('No reminders set'),
                  );
                }
                return ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.alarm,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          reminder.time.format(context),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(reminder.formattedDays),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: reminder.isActive,
                              onChanged: (value) => context
                                  .read<ReminderProvider>()
                                  .toggleReminder(reminder.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => context
                                  .read<ReminderProvider>()
                                  .removeReminder(reminder.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.access_time,
          color: Theme.of(context).primaryColor,
        ),
        title: const Text('Reminder Time'),
        subtitle: Text(_selectedTime.format(context)),
        onTap: _selectTime,
      ),
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeat on',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(
            7,
            (index) => FilterChip(
              label: Text(_weekDays[index]),
              selected: _selectedDays.contains(index + 1),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(index + 1);
                  } else {
                    _selectedDays.remove(index + 1);
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showStopAllRemindersDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop All Reminders'),
        content: const Text(
          'Are you sure you want to stop all reminders?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              // First cancel all notifications
              await _reminderService.cancelAllReminders();
              // Then clear all reminders from provider (which should also clear preferences)
              if (mounted) {
                await context.read<ReminderProvider>().removeAllReminders();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All reminders have been stopped'),
                  ),
                );
              }
            },
            child: const Text('STOP ALL'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        // Auto-select today's day when time is picked
        final today = DateTime.now().weekday;
        if (!_selectedDays.contains(today)) {
          _selectedDays.add(today);
        }
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
        ),
      );
      return;
    }

    try {
      final reminder = ReminderModel(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        time: _selectedTime,
        selectedDays: List.from(_selectedDays),
      );

      await context.read<ReminderProvider>().addReminder(reminder);

      setState(() {
        _selectedDays.clear();
        _selectedTime = TimeOfDay.now();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder set successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set reminder: ${e.toString()}'),
          ),
        );
      }
    }
  }
}
