import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:spendulum/models/budget.dart';
import 'package:spendulum/providers/budget_provider.dart';
import 'package:spendulum/features/budget/widgets/edit_budget.dart';
import 'package:spendulum/ui/widgets/logger.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;

  const BudgetCard({
    Key? key,
    required this.budget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = budget.progress;
    final isExceeded = budget.isExceeded;

    Color progressColor = theme.primaryColor;
    if (progress > 0.8) {
      progressColor = theme.colorScheme.error;
    } else if (progress > 0.6) {
      progressColor = Colors.orange;
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(context, theme),
            SizedBox(height: 16),
            _buildProgressSection(
                context, theme, progressColor, progress, isExceeded),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                budget.name,
                style: theme.textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '${budget.period.toString().split('.').last.toUpperCase()} Budget',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        _buildActionMenu(context, theme),
      ],
    );
  }

  Widget _buildActionMenu(BuildContext context, ThemeData theme) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (value) => _handleBudgetAction(context, value),
      itemBuilder: (context) => [
        _buildMenuItem(
          value: 'edit',
          icon: Icons.edit,
          title: 'Edit',
          theme: theme,
        ),
        if (budget.status == BudgetStatus.active)
          _buildMenuItem(
            value: 'pause',
            icon: Icons.pause,
            title: 'Pause',
            theme: theme,
          )
        else
          _buildMenuItem(
            value: 'resume',
            icon: Icons.play_arrow,
            title: 'Resume',
            theme: theme,
          ),
        _buildMenuItem(
          value: 'delete',
          icon: Icons.delete,
          title: 'Delete',
          theme: theme,
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String title,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? theme.colorScheme.error : null;

    return PopupMenuItem(
      value: value,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    ThemeData theme,
    Color progressColor,
    double progress,
    bool isExceeded,
  ) {
    return Row(
      children: [
        CircularPercentIndicator(
          radius: 30.0,
          lineWidth: 8.0,
          percent: progress.clamp(0.0, 1.0),
          center: Text(
            '${(progress * 100).toInt()}%',
            style: theme.textTheme.bodySmall,
          ),
          progressColor: progressColor,
          backgroundColor: theme.dividerColor,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressBar(
                context,
                'Spent',
                budget.spent,
                budget.amount,
                progressColor,
                theme,
              ),
              SizedBox(height: 8),
              Text(
                'Remaining: ₹${budget.remaining.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: isExceeded
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String label,
    double current,
    double total,
    Color progressColor,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(
              '₹${current.toStringAsFixed(2)} / ₹${total.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: (current / total).clamp(0.0, 1.0),
          backgroundColor: theme.dividerColor,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
      ],
    );
  }

  void _handleBudgetAction(BuildContext context, String action) {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    switch (action) {
      case 'edit':
        _showEditDialog(context);
        break;
      case 'pause':
        _showPauseConfirmation(context, budgetProvider);
        break;
      case 'resume':
        _showResumeConfirmation(context, budgetProvider);
        break;
      case 'delete':
        _showDeleteConfirmation(context, budgetProvider);
        break;
    }
  }

  void _showEditDialog(BuildContext context) {
    AppLogger.info('Opening edit budget dialog for budget: ${budget.id}');
    showDialog(
      context: context,
      builder: (context) => EditBudgetDialog(budget: budget),
    );
  }

  void _showPauseConfirmation(BuildContext context, BudgetProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pause Budget'),
        content: Text('Are you sure you want to pause this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.pauseBudget(budget.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Budget paused')),
              );
            },
            child: Text('Pause'),
          ),
        ],
      ),
    );
  }

  void _showResumeConfirmation(BuildContext context, BudgetProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resume Budget'),
        content: Text('Are you sure you want to resume this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.resumeBudget(budget.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Budget resumed')),
              );
            },
            child: Text('Resume'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, BudgetProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Budget'),
        content: Text(
            'Are you sure you want to delete this budget? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeBudget(budget.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Budget deleted')),
              );
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to check if budget is exceeded
extension BudgetExtension on Budget {
  bool get isExceeded => spent > amount;
  double get progress => spent / amount;
}
