import 'package:spendulum/ui/widgets/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/ui/screens/home_screen.dart';
import 'package:spendulum/ui/widgets/custom_color_picker.dart';
import 'package:spendulum/ui/widgets/custom_text_field.dart';
import 'package:spendulum/ui/widgets/custom_dropdown.dart';
import 'package:flutter/services.dart';
import 'package:spendulum/ui/widgets/account_cards/account_card.dart';
import 'package:spendulum/ui/widgets/animated_background.dart';

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
  Color _color = Colors.blue;
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
      child: AnimatedBackground(
        color: Colors.blue, // Set your desired background color here
        child: Scaffold(
          backgroundColor:
              Colors.transparent, // Make scaffold background transparent
          appBar: AppBar(
            backgroundColor: Colors.blue.shade700.withOpacity(
                0.8), // Set a solid background color with some opacity
            // Make app bar background transparent
            elevation: 4, // Remove app bar shadow
            title: Text(
              widget.isInitialSetup
                  ? 'Add Your First Account'
                  : 'Manage Accounts',
              style: TextStyle(color: Colors.white),
            ),
            leading: widget.isInitialSetup
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
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
                    if (widget.isInitialSetup)
                      _buildAccountForm(), // Show the account form
                    if (widget.isInitialSetup)
                      SizedBox(height: 24), // Add spacing
                    if (widget.isInitialSetup)
                      _buildSubmitButton(), // Show the submit button
                    if (!widget.isInitialSetup) _buildAccountList(),
                    if (!widget.isInitialSetup) SizedBox(height: 24),
                    if (!widget.isInitialSetup) _buildAddAccountButton(),
                  ],
                ),
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

  void _showSetupCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 80, color: Colors.green),
                SizedBox(height: 24),
                Text('All set up!',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Your account has been created successfully.',
                    textAlign: TextAlign.center),
                SizedBox(height: 24),
                ElevatedButton(
                  child: Text('Start Budgeting'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No accounts found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Add an account to get started',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAccountDialog(),
            icon: Icon(Icons.add),
            label: Text('Create an Account'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
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
        isSelected: true, // Adjust selection logic as needed
        onTap: () => {
          _showEditAccountDialog(account)
        }, // This can be left empty or removed
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () =>
              _showDeleteAccountDialog(account), // Show delete dialog
        ),
      ),
    );
  }

  void _showAddAccountDialog() {
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
                                color: Colors
                                    .white)), // Change text color to white
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors
                              .redAccent, // Background color for the button
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
                          backgroundColor: Colors
                              .blueAccent, // Background color for the button
                          foregroundColor: Colors.white, // Text color
                          elevation: 5, // Add elevation for shadow
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
                                backgroundColor: Colors.green,
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

  Widget _buildTextFormField(String label, Function(String?) onSaved,
      {TextInputType? keyboardType, String? initialValue}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      initialValue: initialValue,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, Function(String?) onChanged,
      {String? initialValue}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: initialValue ?? items[0],
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.black54, // Semi-transparent background for contrast
          padding: EdgeInsets.all(8), // Padding around the text
          child: const Text(
            'Account Color',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black, // Shadow color
                  offset: Offset(1.0, 1.0), // Shadow offset
                ),
              ], // Change to a more visible color
            ),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _showColorPalette,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPalette() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Account Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _color,
              onColorChanged: (Color color) {
                setState(() => _color = color);
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
          ),
          SizedBox(height: 16),
          CustomTextField(
            label: 'Account Number',
            onSaved: (value) => _accountNumber = value!,
            initialValue: _accountNumber,
          ),
          SizedBox(height: 16),
          CustomDropdown(
            label: 'Account Type',
            items: _accountTypes,
            onChanged: (value) => _accountType = value!,
            initialValue: _accountType,
          ),
          SizedBox(height: 16),
          CustomTextField(
            label: 'Balance',
            onSaved: (value) => _balance = double.parse(value!),
            keyboardType: TextInputType.number,
            initialValue: _balance == 0.0 ? '' : _balance.toString(),
            onTap: () {
              setState(() {
                _balance = 0; // Clear the prefilled value
              });
            },
          ),
          SizedBox(height: 16),
          CustomDropdown(
            label: 'Currency',
            items: _currencies,
            onChanged: (value) => _currency = value!,
            initialValue: _currency,
          ),
          SizedBox(height: 16),
          CustomColorPicker(
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
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      child: Text('Skip for now'),
      onPressed: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      ),
    );
  }
}
