import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/ui/widgets/account_cards/account_card.dart';
import 'package:spendulum/ui/widgets/account_cards/add_account_card.dart';
import 'package:spendulum/ui/screens/account_management_screen.dart';

class AccountCardsList extends StatelessWidget {
  const AccountCardsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        print('Number of accounts: ${accountProvider.accounts.length}');
        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: accountProvider.accounts.length + 1,
            itemBuilder: (context, index) {
              print('Building item at index: $index');
              if (index < accountProvider.accounts.length) {
                final account = accountProvider.accounts[index];
                print(
                    'Account ID: ${account.id}, Selected ID: ${accountProvider.selectedAccountId}');
                return AccountCard(
                  account: account,
                  isSelected: account.id == accountProvider.selectedAccountId,
                  onTap: () => accountProvider.selectAccount(account.id),
                );
              } else {
                print('Building AddAccountCard');
                return AddAccountCard(
                  onTap: () {
                    print('AddAccountCard tapped');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AccountManagementScreen(
                          isInitialSetup: false,
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        );
      },
    );
  }
}
