import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/account_provider.dart';
import 'package:budget_buddy/widgets/account_cards/account_card.dart';
import 'package:budget_buddy/widgets/account_cards/add_account_card.dart';
import 'package:budget_buddy/screens/account_management_screen.dart';

class AccountCardsList extends StatelessWidget {
  const AccountCardsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: accountProvider.accounts.length + 1,
            itemBuilder: (context, index) {
              if (index == accountProvider.accounts.length) {
                return Align(
                  alignment: Alignment.center,
                  child: AddAccountCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => AccountManagementScreen()),
                    ),
                  ),
                );
              }
              final account = accountProvider.accounts[index];
              return AccountCard(
                account: account,
                isSelected: account.id == accountProvider.selectedAccountId,
                onTap: () => accountProvider.selectAccount(account.id),
              );
            },
          ),
        );
      },
    );
  }
}
