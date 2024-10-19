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
import 'package:spendulum/constants/app_colors.dart'; // Import AppColors

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
  Color _color = AppColors.primary; // Use AppColors.primary
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
        backgroundColor: AppColors.background, // Use AppColors.background
        appBar: AppBar(
          backgroundColor:
              AppColors.primary.withOpacity(0.8), // Use AppColors.primary
          elevation: 4,
          title: Text(
            widget.isInitialSetup
                ? 'Add Your First Account'
                : 'Manage Accounts',
            style: TextStyle(color: AppColors.text), // Use AppColors.text
          ),
          leading: widget.isInitialSetup
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.text, // Use AppColors.text
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
                  if (widget.isInitialSetup) _buildHeaderText(),
                  SizedBox(height: 24),
                  if (widget.isInitialSetup) _buildAccountForm(),
                  if (widget.isInitialSetup) SizedBox(height: 24),
                  if (widget.isInitialSetup) _buildSubmitButton(),
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
        return AlertDialog(
          title: Text('Exit Setup?'),
          content: Text(
              'Are you sure you want to exit the account setup? You can always add accounts later.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Exit'),
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
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: accountProvider.accounts.length,
          itemBuilder: (context, index) {
            return _buildAccountTile(accountProvider.accounts[index]);
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
        return AlertDialog(
          title: Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deleting your account will delete your expense details.'),
              SizedBox(height: 16),
              TextField(
                controller: _accountNumberController,
                decoration: InputDecoration(labelText: 'Enter Account Number'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                final accountProvider =
                    Provider.of<AccountProvider>(context, listen: false);
                accountProvider.deleteAccount(
                    account.id, _accountNumberController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountTile(Account account) {
    return GestureDetector(
      onTap: () {
        _showEditAccountDialog(account);
      },
      child: AccountCard(
        account: account,
        isSelected: true,
        onTap: () => {_showEditAccountDialog(account)},
        trailing: IconButton(
          icon:
              Icon(Icons.delete, color: AppColors.error), // Use AppColors.error
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
    _color = AppColors.primary; // Use AppColors.primary
    _currency = 'USD';
  }

  void _showAddAccountDialog() {
    resetAccountForm();
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  _buildAccountForm(),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Cancel',
                            style: TextStyle(
                                color: AppColors.text)), // Use AppColors.text
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              AppColors.error, // Use AppColors.error
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        child: Text('Add'),
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor:
                              AppColors.primary, // Use AppColors.primary
                          foregroundColor: AppColors.text, // Use AppColors.text
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
                  _buildAccountForm(),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        child: Text('Save'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final accountProvider =
                                Provider.of<AccountProvider>(context,
                                    listen: false);
                            accountProvider.updateAccount(
                                account.id,
                                _name,
                                _accountNumber,
                                _accountType,
                                _balance,
                                _color,
                                _currency);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Account updated successfully'),
                                backgroundColor:
                                    AppColors.primary, // Use AppColors.primary
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      accountProvider.addAccount(
          _name, _accountNumber, _accountType, _balance, _color, _currency);

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

  Widget _buildHeaderText() {
    return AnimatedOpacity(
      opacity: _fadeInAnimation.value,
      duration: Duration(milliseconds: 500),
      child: Text(
        "Let's set up your first account to get started!",
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text), // Use AppColors.text
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAccountForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomTextField(
            label: 'Account Name',
            onSaved: (value) => _name = value!,
            initialValue: _name,
            textColor: AppColors.text, // Use AppColors.text
          ),
          SizedBox(height: 16),
          CustomTextField(
            label: 'Account Number',
            onSaved: (value) => _accountNumber = value!,
            initialValue: _accountNumber,
            textColor: AppColors.text, // Use AppColors.text
          ),
          SizedBox(height: 16),
          CustomDropdown(
            label: 'Account Type',
            items: _accountTypes,
            onChanged: (value) => _accountType = value!,
            initialValue: _accountType,
            textColor: AppColors.text, // Use AppColors.text
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
            textColor: AppColors.text, // Use AppColors.text
          ),
          SizedBox(height: 16),
          CustomDropdown(
            label: 'Currency',
            items: _currencies,
            onChanged: (value) => _currency = value!,
            initialValue: _currency,
            textColor: AppColors.text, // Use AppColors.text
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

  Widget _buildSubmitButton() {
    return AnimatedOpacity(
      opacity: _fadeInAnimation.value,
      duration: Duration(milliseconds: 500),
      child: ElevatedButton(
        child: Text(widget.isInitialSetup ? 'Create Account' : 'Save'),
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // Use AppColors.primary
          foregroundColor: AppColors.text, // Use AppColors.text
          padding: EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}