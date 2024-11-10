import 'package:get_it/get_it.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/providers/income_provider.dart';
import 'package:spendulum/providers/recurring_transaction_provider.dart';
import 'package:spendulum/providers/budget_provider.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // Register providers as singletons
  getIt.registerLazySingleton<AccountProvider>(() => AccountProvider());

  getIt.registerLazySingleton<BudgetProvider>(() => BudgetProvider());

  getIt.registerLazySingleton<ExpenseProvider>(() => ExpenseProvider(
        getIt<AccountProvider>(),
        getIt<BudgetProvider>(),
      ));

  getIt.registerLazySingleton<IncomeProvider>(() => IncomeProvider(
        getIt<AccountProvider>(),
      ));

  getIt.registerLazySingleton<RecurringTransactionProvider>(
      () => RecurringTransactionProvider(
            getIt<ExpenseProvider>(),
            getIt<IncomeProvider>(),
          ));
}
