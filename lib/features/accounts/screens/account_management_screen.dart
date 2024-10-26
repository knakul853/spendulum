import 'package:spendulum/ui/widgets/logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/ui/screens/home_screen.dart';
import 'package:spendulum/ui/widgets/custom_color_picker.dart';
import 'package:spendulum/ui/widgets/custom_text_field.dart';
import 'package:spendulum/ui/widgets/custom_dropdown.dart';
import 'package:flutter/services.dart';
import "package:spendulum/features/accounts/widgets/account_card.dart";

//Added for error handling
import 'dart:developer' as developer;

class AccountManagementScreen extends StatefulWidget {
  final Function? onBackPressed;
  final bool isInitialSetup;

  const AccountManagementScreen({
    super.key,
    this.onBackPressed,
    required this.isInitialSetup,
  });

  @override
  _AccountManagementScreenState createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _accountNumber = '';
  String _accountType = 'General';
  double _balance = 0;
  Color _color = Colors.blue; // Initialize with a default color
  String _currency = 'USD';

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  final List<String> _accountTypes = [
    'General',
    'Cash',
    'Current Account',
    'Credit Card',
    'Savings Account',
    'Bonus',
    'Insurance',
    'Investment',
    'Loan',
    'Mortgage',
    'Account with Overdraft',
    'Other'
  ];

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'Other'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme

    AppLogger.info(
        'AccountManagementScreen build: isInitialSetup = ${widget.isInitialSetup}');

    return WillPopScope(
      onWillPop: () async {
        if (widget.isInitialSetup) {
          _showExitConfirmationDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              theme.primaryColor.withOpacity(0.8), // Use theme color
          elevation: 4,
          title: Text(
            widget.isInitialSetup
                ? 'Add Your First Account'
                : 'Manage Accounts',
            style: theme.textTheme.titleLarge!.copyWith(
                color: theme.colorScheme.onPrimary), // Use theme color
          ),
          leading: widget.isInitialSetup
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onPrimary, // Use theme color
                  ),
                  onPressed: _showExitConfirmationDialog,
                )
              : null,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isInitialSetup) _buildHeaderText(theme),
                  SizedBox(height: 24),
                  if (widget.isInitialSetup) _buildAccountForm(theme),
                  if (widget.isInitialSetup) SizedBox(height: 24),
                  if (widget.isInitialSetup) _buildSubmitButton(theme),
                  if (!widget.isInitialSetup) _buildAccountList(),
                  if (!widget.isInitialSetup) SizedBox(height: 24),
                  if (!widget.isInitialSetup) _buildAddAccountButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    AppLogger.info(
        'AccountManagementScreen: isInitialSetup = ${widget.isInitialSetup}');

    super.initState();
    _accountType = _accountTypes[0];
    _currency = _currencies[0];

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeInAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    // Ensure the widget rebuilds after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context); // Get theme here
        return AlertDialog(
          title: Text('Exit Setup?', style: theme.textTheme.titleMedium),
          content: Text(
              'Are you sure you want to exit the account setup? You can always add accounts later.',
              style: theme.textTheme.bodyMedium),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: theme.textTheme.bodyMedium),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Exit', style: theme.textTheme.bodyMedium),
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddAccountButton() {
    return FloatingActionButton(
      onPressed: () => _showAddAccountDialog(),
      child: Icon(Icons.add),
    );
  }

  Widget _buildAccountList() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        final theme = Theme.of(context); // Get theme here
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: accountProvider.accounts.length,
          itemBuilder: (context, index) {
            return _buildAccountTile(accountProvider.accounts[index], theme);
          },
        );
      },
    );
  }

  // Add this method to show the delete confirmation dialog
  void _showDeleteAccountDialog(Account account) {
    final TextEditingController _accountNumberController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context); // Get theme here
        return AlertDialog(
          title: Text('Delete Account', style: theme.textTheme.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deleting your account will delete your expense details.',
                  style: theme.textTheme.bodyMedium),
              SizedBox(height: 16),
              TextField(
                controller: _accountNumberController,
                decoration: InputDecoration(labelText: 'Enter Account Number'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: theme.textTheme.bodyMedium),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: theme.textTheme.bodyMedium),
              onPressed: () {
                final accountProvider =
                    Provider.of<AccountProvider>(context, listen: false);
                try {
                  accountProvider.deleteAccount(
                      account.id, _accountNumberController.text);
                } catch (e) {
                  developer.log("Error deleting account: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting account'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountTile(Account account, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        _showEditAccountDialog(account);
      },
      child: AccountCard(
        account: account,
        isSelected: true,
        onTap: () => {_showEditAccountDialog(account)},
        trailing: IconButton(
          icon: Icon(Icons.delete,
              color: theme.colorScheme.error), // Use theme color
          onPressed: () => _showDeleteAccountDialog(account),
        ),
      ),
    );
  }

  void resetAccountForm() {
    _name = "";
    _accountNumber = '';
    _accountType = 'General';
    _balance = 0;
    _color = Colors.blue; // Initialize with a default color
    _currency = 'USD';
  }

  void _showAddAccountDialog() {
    resetAccountForm();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context); // Get theme here
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(24),
            constraints: BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Account',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24),
                  _buildAccountForm(theme),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child:
                            Text('Cancel', style: theme.textTheme.bodyMedium),
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.error, // Use theme color
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        child: Text('Add', style: theme.textTheme.bodyMedium),
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor:
                              theme.primaryColor, // Use theme color
                          foregroundColor:
                              theme.colorScheme.onPrimary, // Use theme color
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditAccountDialog(Account account) {
    setState(() {
      _name = account.name;
      _accountNumber = account.accountNumber;
      _accountType = account.accountType;
      _balance = account.balance;
      _color = account.color;
      _currency = account.currency;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context); // Get theme here
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(24),
            constraints: BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Account',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24),
                  _buildAccountForm(theme),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child:
                            Text('Cancel', style: theme.textTheme.bodyMedium),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        child: Text('Save', style: theme.textTheme.bodyMedium),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final accountProvider =
                                Provider.of<AccountProvider>(context,
                                    listen: false);
                            try {
                              accountProvider.updateAccount(
                                  account.id,
                                  _name,
                                  _accountNumber,
                                  _accountType,
                                  _balance,
                                  _color,
                                  _currency);
                            } catch (e) {
                              developer.log("Error updating account: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating account'),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            }
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Account updated successfully'),
                                backgroundColor:
                                    theme.primaryColor, // Use theme color
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.all(10),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitForm() {
    final theme = Theme.of(context); // Get theme here
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      try {
        accountProvider.addAccount(
            _name, _accountNumber, _accountType, _balance, _color, _currency);
      } catch (e) {
        developer.log("Error adding account: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding account'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }

      AppLogger.info('Account created: $_name');

      if (widget.isInitialSetup) {
        AppLogger.info("Going to home screen");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        AppLogger.info("Closing dialog");
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildHeaderText(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _fadeInAnimation.value,
      duration: Duration(milliseconds: 500),
      child: Text(
        "Let's set up your first account to get started!",
        style: theme.textTheme.headlineMedium!
            .copyWith(color: theme.colorScheme.onSurface), // Use theme color
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAccountForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomTextField(
            label: 'Account Name',
            onSaved: (value) => _name = value!,
            initialValue: _name,
            textColor: theme.colorScheme.onSurface, // Use theme color
          ),
          SizedBox(height: 16),
          CustomTextField(
            label: 'Account Number',
            onSaved: (value) => _accountNumber = value!,
            initialValue: _accountNumber,
            textColor: theme.colorScheme.onSurface, // Use theme color
          ),
          SizedBox(height: 16),
          CustomDropdown(
            label: 'Account Type',
            items: _accountTypes,
            onChanged: (value) => _accountType = value!,
            initialValue: _accountType,
            textColor: theme.colorScheme.onSurface, // Use theme color
          ),
          SizedBox(height: 16),
          CustomTextField(
            label: 'Balance',
            onSaved: (value) => _balance = double.parse(value!),
            keyboardType: TextInputType.number,
            initialValue: _balance == 0.0 ? '' : _balance.toString(),
            onTap: () {
              setState(() {
                _balance = 0;
              });
            },
            textColor: theme.colorScheme.onSurface, // Use theme color
          ),
          SizedBox(height: 16),
          CustomDropdown(
            label: 'Currency',
            items: _currencies,
            onChanged: (value) => _currency = value!,
            initialValue: _currency,
            textColor: theme.colorScheme.onSurface, // Use theme color
          ),
          SizedBox(height: 16),
          CustomColorPicker(
            key: ValueKey(_color),
            initialColor: _color,
            onColorChanged: (color) => setState(() => _color = color),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _fadeInAnimation.value,
      duration: Duration(milliseconds: 500),
      child: ElevatedButton(
        child: Text(widget.isInitialSetup ? 'Create Account' : 'Save',
            style: theme.textTheme.bodyMedium),
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor, // Use theme color
          foregroundColor: theme.colorScheme.onPrimary, // Use theme color
          padding: EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
