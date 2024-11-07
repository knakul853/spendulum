import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/budget_provider.dart';
import 'package:spendulum/models/budget.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/features/budget/widgets/add_budget.dart';
import 'package:spendulum/features/budget/widgets/edit_budget.dart';
import 'package:spendulum/features/budget/widgets/budget_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  BudgetFilter _selectedFilter = BudgetFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budgets',
          style: theme.textTheme.titleLarge!
              .copyWith(color: theme.colorScheme.onPrimary),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(context),
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, _) {
          final allBudgets = budgetProvider.budgets;
          final filteredBudgets = _getFilteredBudgets(allBudgets);

          if (allBudgets.isEmpty) {
            return _buildEmptyState(context);
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: _buildSummaryCards(context, budgetProvider),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Budgets',
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildBudgetFilters(context),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: filteredBudgets.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedFilter == BudgetFilter.active
                                    ? Icons.play_circle_outline
                                    : Icons.pause_circle_outline,
                                size: 48,
                                color:
                                    theme.colorScheme.primary.withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                _selectedFilter == BudgetFilter.active
                                    ? 'No active budgets'
                                    : 'No paused budgets',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => BudgetCard(
                            budget: filteredBudgets[index],
                            onTap: () => _showBudgetDetails(
                                context, filteredBudgets[index]),
                          ),
                          childCount: filteredBudgets.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Budget> _getFilteredBudgets(List<Budget> budgets) {
    switch (_selectedFilter) {
      case BudgetFilter.active:
        return budgets
            .where((budget) => budget.status == BudgetStatus.active)
            .toList();
      case BudgetFilter.paused:
        return budgets
            .where((budget) => budget.status == BudgetStatus.paused)
            .toList();
      case BudgetFilter.all:
      default:
        return budgets;
    }
  }

  Widget _buildBudgetFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: Text('All'),
            selected: _selectedFilter == BudgetFilter.all,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = BudgetFilter.all;
              });
            },
          ),
          SizedBox(width: 8),
          FilterChip(
            label: Text('Active'),
            selected: _selectedFilter == BudgetFilter.active,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = BudgetFilter.active;
              });
            },
          ),
          SizedBox(width: 8),
          FilterChip(
            label: Text('Paused'),
            selected: _selectedFilter == BudgetFilter.paused,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = BudgetFilter.paused;
              });
            },
          ),
        ],
      ),
    );
  }

  void _showBudgetDetails(BuildContext context, Budget budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Budget Details',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  _buildDetailItem(context, 'Name', budget.name),
                  _buildDetailItem(context, 'Amount',
                      '₹${budget.amount.toStringAsFixed(2)}'),
                  _buildDetailItem(context, 'Period',
                      budget.period.toString().split('.').last.toUpperCase()),
                  _buildDetailItem(context, 'Status',
                      budget.status.toString().split('.').last.toUpperCase()),
                  _buildDetailItem(
                      context, 'Start Date', _formatDate(budget.startDate)),
                  _buildDetailItem(
                      context, 'End Date', _formatDate(budget.endDate)),
                  // _buildDetailItem(context, 'Categories',
                  //     budget.categoryIds.map((c) => c.).join(', ')),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditBudgetDialog(context, budget);
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Edit'),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          final provider = Provider.of<BudgetProvider>(context,
                              listen: false);
                          if (budget.status == BudgetStatus.active) {
                            provider.pauseBudget(budget.id);
                          } else {
                            provider.resumeBudget(budget.id);
                          }
                          Navigator.pop(context);
                        },
                        icon: Icon(budget.status == BudgetStatus.active
                            ? Icons.pause
                            : Icons.play_arrow),
                        label: Text(budget.status == BudgetStatus.active
                            ? 'Pause'
                            : 'Resume'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddBudgetDialog(BuildContext context) {
    AppLogger.info('Opening add budget dialog');
    showDialog(
      context: context,
      builder: (context) => const AddBudgetDialog(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: theme.primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No budgets yet',
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Create a budget to start tracking your expenses',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddBudgetDialog(context),
            icon: Icon(Icons.add),
            label: Text('Create Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
      BuildContext context, BudgetProvider budgetProvider) {
    final theme = Theme.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          context,
          'Total Budgeted',
          '₹${budgetProvider.getTotalBudgetedAmount().toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          theme.primaryColor,
        ),
        _buildSummaryCard(
          context,
          'Total Spent',
          '₹${budgetProvider.getTotalSpentAmount().toStringAsFixed(2)}',
          Icons.payments,
          theme.colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String amount,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            Spacer(),
            Text(
              title,
              style: theme.textTheme.titleSmall,
            ),
            SizedBox(height: 4),
            Text(
              amount,
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    AppLogger.info('Opening edit budget dialog for budget: ${budget.id}');
    showDialog(
      context: context,
      builder: (context) => EditBudgetDialog(budget: budget),
    );
  }
}

///Delete below code

// class BudgetScreen1 extends StatelessWidget {
//   const BudgetScreen1({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Budgets',
//           style: theme.textTheme.titleLarge!
//               .copyWith(color: theme.colorScheme.onPrimary),
//         ),
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () => _showAddBudgetDialog(context),
//           ),
//         ],
//       ),
//       body: Consumer<BudgetProvider>(
//         builder: (context, budgetProvider, _) {
//           final budgets = budgetProvider.budgets;

//           if (budgets.isEmpty) {
//             return _buildEmptyState(context);
//           }

//           return CustomScrollView(
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: _buildSummaryCards(context, budgetProvider),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Your Budgets',
//                         style: theme.textTheme.titleMedium!.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       _buildBudgetFilters(context),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverPadding(
//                 padding: EdgeInsets.all(16),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) => BudgetCard(budget: budgets[index]),
//                     childCount: budgets.length,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBudgetFilters(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           FilterChip(
//             label: Text('All'),
//             selected: true,
//             onSelected: (selected) {
//               // Implement filter logic
//             },
//           ),
//           SizedBox(width: 8),
//           FilterChip(
//             label: Text('Active'),
//             selected: false,
//             onSelected: (selected) {
//               // Implement filter logic
//             },
//           ),
//           SizedBox(width: 8),
//           FilterChip(
//             label: Text('Paused'),
//             selected: false,
//             onSelected: (selected) {
//               // Implement filter logic
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     return Consumer<BudgetProvider>(
//       builder: (context, budgetProvider, _) {
//         return ListView(
//           padding: EdgeInsets.all(16),
//           children: [
//             _buildSummaryCards(context, budgetProvider),
//             SizedBox(height: 24),
//             _buildBudgetsList(context, budgetProvider),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildBudgetsList(
//       BuildContext context, BudgetProvider budgetProvider) {
//     final budgets = budgetProvider.budgets;
//     if (budgets.isEmpty) {
//       return _buildEmptyState(context);
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Active Budgets',
//           style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         SizedBox(height: 16),
//         ...budgets.map((budget) => _buildBudgetCard(context, budget)).toList(),
//       ],
//     );
//   }

//   Widget _buildBudgetCard(BuildContext context, Budget budget) {
//     final theme = Theme.of(context);
//     final progress = budget.progress;
//     final isExceeded = budget.isExceeded;

//     Color progressColor = theme.primaryColor;
//     if (progress > 0.8) {
//       progressColor = theme.colorScheme.error;
//     } else if (progress > 0.6) {
//       progressColor = Colors.orange; //TODO: theis color should come from theme.
//     }

//     return Card(
//       elevation: 2,
//       margin: EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         budget.name,
//                         style: theme.textTheme.titleMedium!
//                             .copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         '${budget.period.toString().split('.').last.toUpperCase()} Budget',
//                         style: theme.textTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ),
//                 PopupMenuButton<String>(
//                   onSelected: (value) =>
//                       _handleBudgetAction(context, value, budget),
//                   itemBuilder: (context) => [
//                     PopupMenuItem(
//                       value: 'edit',
//                       child: ListTile(
//                         leading: Icon(Icons.edit),
//                         title: Text('Edit'),
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                     ),
//                     if (budget.status == BudgetStatus.active)
//                       PopupMenuItem(
//                         value: 'pause',
//                         child: ListTile(
//                           leading: Icon(Icons.pause),
//                           title: Text('Pause'),
//                           contentPadding: EdgeInsets.zero,
//                         ),
//                       )
//                     else
//                       PopupMenuItem(
//                         value: 'resume',
//                         child: ListTile(
//                           leading: Icon(Icons.play_arrow),
//                           title: Text('Resume'),
//                           contentPadding: EdgeInsets.zero,
//                         ),
//                       ),
//                     PopupMenuItem(
//                       value: 'delete',
//                       child: ListTile(
//                         leading:
//                             Icon(Icons.delete, color: theme.colorScheme.error),
//                         title: Text('Delete',
//                             style: TextStyle(color: theme.colorScheme.error)),
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 CircularPercentIndicator(
//                   radius: 30.0,
//                   lineWidth: 8.0,
//                   percent: progress,
//                   center: Text(
//                     '${(progress * 100).toInt()}%',
//                     style: theme.textTheme.bodySmall,
//                   ),
//                   progressColor: progressColor,
//                   backgroundColor: theme.dividerColor,
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildProgressBar(
//                         context,
//                         'Spent',
//                         budget.spent,
//                         budget.amount,
//                         progressColor,
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Remaining: ₹${budget.remaining.toStringAsFixed(2)}',
//                         style: theme.textTheme.bodyMedium!.copyWith(
//                           color: isExceeded
//                               ? theme.colorScheme.error
//                               : theme.colorScheme.onSurface,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProgressBar(BuildContext context, String label, double current,
//       double total, Color progressColor) {
//     final theme = Theme.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(label, style: theme.textTheme.bodySmall),
//             Text(
//               '₹${current.toStringAsFixed(2)} / ₹${total.toStringAsFixed(2)}',
//               style: theme.textTheme.bodySmall,
//             ),
//           ],
//         ),
//         SizedBox(height: 4),
//         LinearProgressIndicator(
//           value: (current / total).clamp(0.0, 1.0),
//           backgroundColor: theme.dividerColor,
//           valueColor: AlwaysStoppedAnimation<Color>(progressColor),
//         ),
//       ],
//     );
//   }

//   void _handleBudgetAction(BuildContext context, String action, Budget budget) {
//     final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

//     switch (action) {
//       case 'edit':
//         _showEditBudgetDialog(context, budget);
//         break;
//       case 'pause':
//         budgetProvider.pauseBudget(budget.id);
//         break;
//       case 'resume':
//         budgetProvider.resumeBudget(budget.id);
//         break;
//       case 'delete':
//         _showDeleteConfirmation(context, budget);
//         break;
//     }
//   }

//   void _showDeleteConfirmation(BuildContext context, Budget budget) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Budget'),
//         content: Text('Are you sure you want to delete this budget?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Provider.of<BudgetProvider>(context, listen: false)
//                   .removeBudget(budget.id);
//               Navigator.pop(context);
//             },
//             child: Text('Delete'),
//             style: TextButton.styleFrom(
//               foregroundColor: Theme.of(context).colorScheme.error,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Add Budget Dialog implementation would go here
//   void _showAddBudgetDialog(BuildContext context) {
//     AppLogger.info('Opening add budget dialog');
//     showDialog(
//       context: context,
//       builder: (context) => const AddBudgetDialog(),
//     );
//   }

//   // Edit Budget Dialog implementation would go here
//   void _showEditBudgetDialog(BuildContext context, Budget budget) {
//     AppLogger.info('Opening edit budget dialog for budget: ${budget.id}');
//     showDialog(
//       context: context,
//       builder: (context) => EditBudgetDialog(budget: budget),
//     );
//   }
// }

enum BudgetFilter {
  all,
  active,
  paused,
}
