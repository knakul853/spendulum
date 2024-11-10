import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/providers/recurring_transaction_provider.dart';
import 'package:spendulum/ui/widgets/recurring_settings_modal.dart';
import 'package:spendulum/models/recurring_transaction.dart';
import 'package:spendulum/utils/currency.dart';

class ManageRecurringScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Recurring'),
      ),
      body: Consumer<RecurringTransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.recurringTransactions;

          if (transactions.isEmpty) {
            return Center(
              child: Text(
                'No recurring transactions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildRecurringTransactionCard(context, transaction);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecurringTransactionCard(
    BuildContext context,
    RecurringTransaction transaction,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(
          transaction.isExpense ? Icons.remove_circle : Icons.add_circle,
          color: transaction.isExpense
              ? Theme.of(context).colorScheme.error
              : Colors.green,
        ),
        title: Text(transaction.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${transaction.frequency.toString().split('.').last} • '
              '${transaction.endDate == null ? 'No end date' : DateFormat.yMMMd().format(transaction.endDate!)}',
            ),
            Text(
              getCurrencySymbol(transaction.amount.toString()),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: transaction.isExpense
                        ? Theme.of(context).colorScheme.error
                        : Colors.green,
                  ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Text(transaction.isActive ? 'Pause' : 'Resume'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) => _handleMenuAction(
            context,
            value.toString(),
            transaction,
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    RecurringTransaction transaction,
  ) {
    final provider =
        Provider.of<RecurringTransactionProvider>(context, listen: false);

    switch (action) {
      case 'edit':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => RecurringSettingsModal(
            isExpense: transaction.isExpense,
            existingTransaction: transaction,
            onSave: (updatedTransaction) {
              provider.updateRecurringTransaction(updatedTransaction);
            },
          ),
        );
        break;
      case 'toggle':
        final updatedTransaction = RecurringTransaction(
          id: transaction.id,
          title: transaction.title,
          amount: transaction.amount,
          accountId: transaction.accountId,
          categoryOrSource: transaction.categoryOrSource,
          description: transaction.description,
          frequency: transaction.frequency,
          startDate: transaction.startDate,
          endDate: transaction.endDate,
          reminderTime: transaction.reminderTime,
          isExpense: transaction.isExpense,
          customDays: transaction.customDays,
          isActive: !transaction.isActive,
        );
        provider.updateRecurringTransaction(updatedTransaction);
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Recurring Transaction'),
            content: const Text(
                'Are you sure you want to delete this recurring transaction?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.deleteRecurringTransaction(transaction.id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }
}
