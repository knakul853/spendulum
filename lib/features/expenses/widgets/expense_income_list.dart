import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/providers/income_provider.dart';
import 'package:spendulum/ui/widgets/expense_list_item.dart';
import 'package:spendulum/ui/widgets/income_list_item.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/ui/widgets/tabBar.dart';
import 'package:spendulum/utils/currency.dart';

class ExpenseIncomeList extends StatefulWidget {
  final String accountId;
  final DateTime selectedMonth;

  const ExpenseIncomeList({
    Key? key,
    required this.accountId,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  _ExpenseIncomeListState createState() => _ExpenseIncomeListState();
}

class _ExpenseIncomeListState extends State<ExpenseIncomeList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'category', 'date', 'amount'
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _tabController.addListener(() {
      // Only trigger when the tab actually changes
      if (_tabController.indexIsChanging) {
        AppLogger.info(
            'ExpenseIncomeList: Tab changed to index ${_tabController.index}');
        _handleTabChange();
      }
    });

    AppLogger.info('ExpenseIncomeList: Initialized with TabController');
  }

  void _handleTabChange() {
    AppLogger.info('ExpenseIncomeList: Handling tab change');
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _searchQuery = '';
        _searchController.clear();
        AppLogger.info('ExpenseIncomeList: Cleared search query');
      }
      _selectedFilter = 'all';
      AppLogger.info('ExpenseIncomeList: Reset filter to all');
      // Don't collapse search when switching tabs if it's expanded
      // _isSearchExpanded = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
    AppLogger.info('ExpenseIncomeList: Disposed TabController');
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _onTabChanged() {
    AppLogger.info('ExpenseIncomeList: Tab changed');
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _searchQuery = '';
        _searchController.clear();
      }
      _selectedFilter = 'all';
      // Don't collapse search when switching tabs if it's expanded
      // _isSearchExpanded = false;
    });
  }

  bool _matchesSearch(dynamic item) {
    if (_searchQuery.isEmpty) return true;

    final isExpenseTab = _tabController.index == 0;
    final categoryOrSource = isExpenseTab ? item.category : item.source;

    switch (_selectedFilter) {
      case 'category':
        return categoryOrSource.toLowerCase().contains(_searchQuery);
      case 'date':
        return DateFormat('MMM dd, yyyy')
            .format(item.date)
            .toLowerCase()
            .contains(_searchQuery);
      case 'amount':
        return item.amount.toString().contains(_searchQuery);
      default:
        return categoryOrSource.toLowerCase().contains(_searchQuery) ||
            item.description.toLowerCase().contains(_searchQuery) ||
            DateFormat('MMM dd, yyyy')
                .format(item.date)
                .toLowerCase()
                .contains(_searchQuery) ||
            item.amount.toString().contains(_searchQuery);
    }
  }

  Widget _buildSearchBar() {
    return Align(
      alignment: _isSearchExpanded ? Alignment.center : Alignment.centerRight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(
              horizontal: _isSearchExpanded ? 16 : 8,
              vertical: 8,
            ),
            height: _isSearchExpanded ? 100 : 48,
            width: _isSearchExpanded ? constraints.maxWidth - 32 : 48,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animate search/back icon
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          turns: _isSearchExpanded ? -0.25 : 0,
                          child: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return RotationTransition(
                                  turns: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                _isSearchExpanded
                                    ? Icons.arrow_back
                                    : Icons.search,
                                key: ValueKey<bool>(_isSearchExpanded),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isSearchExpanded = !_isSearchExpanded;
                                if (!_isSearchExpanded) {
                                  _searchController.clear();
                                  _selectedFilter = 'all';
                                }
                              });
                            },
                          ),
                        ),
                        if (_isSearchExpanded) ...[
                          // Animate TextField appearance
                          Expanded(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _isSearchExpanded ? 1.0 : 0.0,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Search ${_tabController.index == 0 ? 'Expenses' : 'Income'}...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            // Animate clear button
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _searchQuery.isNotEmpty ? 1.0 : 0.0,
                              child: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  // Animate filter chips
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      height: _isSearchExpanded ? 44 : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isSearchExpanded ? 1.0 : 0.0,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildAnimatedFilterChip('All', 'all'),
                              _buildAnimatedFilterChip(
                                  _tabController.index == 0
                                      ? 'Category'
                                      : "Source",
                                  'category'),
                              _buildAnimatedFilterChip('Date', 'date'),
                              _buildAnimatedFilterChip('Amount', 'amount'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedFilterChip(String label, String value) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: _isSearchExpanded ? 1.0 : 0.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isSearchExpanded ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilterChip(
            label: Text(
              label,
              style: TextStyle(fontSize: 12),
            ),
            selected: _selectedFilter == value,
            onSelected: (bool selected) {
              setState(() {
                _selectedFilter = selected ? value : 'all';
              });
            },
            backgroundColor: Theme.of(context).cardColor,
            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
            checkmarkColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            elevation: 0,
            pressElevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(double total, String currency, String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(left: 16, top: 8, bottom: 0, right: 16),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        constraints: BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total $title',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${getCurrencySymbol(currency)}${NumberFormat('#,##0.00').format(total)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        StyledTabBar(controller: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildExpenseList(),
              _buildIncomeList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseList() {
    AppLogger.info('ExpenseIncomeList: Building expense list');
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        final expenses = expenseProvider.getExpensesForMonth(
            widget.selectedMonth,
            accountId: widget.accountId);
        final accountProvider = Provider.of<AccountProvider>(context);
        final accountCurrency =
            accountProvider.getCurrencyCode(widget.accountId);

        // Calculate total expenses
        final totalExpenses = expenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );

        return Column(
          children: [
            _buildTotalCard(totalExpenses, accountCurrency, 'Expenses'),
            Expanded(
              child: _buildList(
                items: expenses,
                itemBuilder: (expense) => ExpenseListItem(
                    expense: expense, currency: accountCurrency),
                emptyMessage: 'No Expenses Found',
                title:
                    '${DateFormat.MMMM().format(widget.selectedMonth)} Expenses',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncomeList() {
    AppLogger.info('ExpenseIncomeList: Building income list');
    return Consumer<IncomeProvider>(
      builder: (context, incomeProvider, _) {
        final incomes = incomeProvider.getIncomesForMonth(widget.selectedMonth,
            accountId: widget.accountId);
        final accountProvider = Provider.of<AccountProvider>(context);
        final accountCurrency =
            accountProvider.getCurrencyCode(widget.accountId);

        // Calculate total income
        final totalIncome = incomes.fold<double>(
          0,
          (sum, income) => sum + income.amount,
        );

        return Column(
          children: [
            _buildTotalCard(totalIncome, accountCurrency, 'Income'),
            Expanded(
              child: _buildList(
                items: incomes,
                itemBuilder: (income) =>
                    IncomeListItem(income: income, currency: accountCurrency),
                emptyMessage: 'No Income Found',
                title:
                    '${DateFormat.MMMM().format(widget.selectedMonth)} Income',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList({
    required List<dynamic> items,
    required Widget Function(dynamic) itemBuilder,
    required String emptyMessage,
    required String title,
  }) {
    // Filter items based on search query
    final filteredItems = items.where(_matchesSearch).toList();

    if (items.isEmpty) {
      return _buildEmptyState('No transactions found for $title');
    }

    if (filteredItems.isEmpty) {
      return _buildEmptyState('No results found for "$_searchQuery"');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: itemBuilder(item),
        );
      },
    );
  }
}
