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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
    AppLogger.info('ExpenseIncomeList: Initialized with TabController');
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

  bool _matchesSearch(dynamic item) {
    if (_searchQuery.isEmpty) return true;

    switch (_selectedFilter) {
      case 'category':
        return item.category.toLowerCase().contains(_searchQuery);
      case 'date':
        return DateFormat('MMM dd, yyyy')
            .format(item.date)
            .toLowerCase()
            .contains(_searchQuery);
      case 'amount':
        return item.amount.toString().contains(_searchQuery);
      default:
        return item.category.toLowerCase().contains(_searchQuery) ||
            item.description.toLowerCase().contains(_searchQuery) ||
            DateFormat('MMM dd, yyyy')
                .format(item.date)
                .toLowerCase()
                .contains(_searchQuery) ||
            item.amount.toString().contains(_searchQuery);
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Category', 'category'),
                _buildFilterChip('Date', 'date'),
                _buildFilterChip('Amount', 'amount'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
        },
        backgroundColor: Theme.of(context).cardColor,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
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

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '\$';
    }
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
              '${_getCurrencySymbol(currency)}${NumberFormat('#,##0.00').format(total)}',
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
