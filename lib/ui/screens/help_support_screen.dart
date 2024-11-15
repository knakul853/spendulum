import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:spendulum/config/env_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:spendulum/utils/email.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: theme.textTheme.titleLarge!
              .copyWith(color: theme.colorScheme.onPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            icon: Icons.question_answer,
            title: 'Frequently Asked Questions',
            subtitle: 'Find answers to common questions',
            onTap: () => _showFAQScreen(context),
          ),
          // _buildSection(
          //   context,
          //   icon: Icons.menu_book,
          //   title: 'User Guide',
          //   subtitle: 'Learn how to use the app effectively',
          //   onTap: () => _showUserGuideScreen(context),
          // ),
          // _buildSection(
          //   context,
          //   icon: Icons.contact_support,
          //   title: 'Contact Support',
          //   subtitle: 'Get in touch with our support team',
          //   onTap: () => _showContactSupport(context),
          // ),
          // _buildSection(
          //   context,
          //   icon: Icons.bug_report,
          //   title: 'Report a Problem',
          //   subtitle: 'Let us know if something isn\'t working',
          //   onTap: () => _showReportProblem(context),
          // ),
          _buildSection(
            context,
            icon: Icons.star_outline,
            title: 'App Feedback',
            subtitle: 'Share your thoughts and suggestions',
            onTap: () => _showFeedbackForm(context),
          ),
          _buildSection(
            context,
            icon: Icons.privacy_tip,
            title: 'Terms & Privacy',
            subtitle: 'View our terms and privacy policy',
            onTap: () => _launchPrivacyPolicy(),
          ),
          _buildSection(
            context,
            icon: Icons.update,
            title: 'Version Info',
            subtitle: 'App version and update information',
            onTap: () => _showVersionInfo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(icon, color: theme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showFAQScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FAQScreen(),
      ),
    );
  }

  void _showUserGuideScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _UserGuideScreen(),
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              onTap: () => _launchEmail('support@spendulum.com'),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Live Chat'),
              onTap: () {
                // Implement live chat functionality
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportProblem(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ProblemReportScreen(),
      ),
    );
  }

  void _showFeedbackForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FeedbackScreen(),
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    const url =
        'https://docs.google.com/document/d/1e-r5vZ1n84z_BTyTbkfVsNUFTvNZU6yPaUckYUP1gH8/edit?usp=sharing';
    try {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Handle error appropriately
    }
  }

  void _showVersionInfo(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Version Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('App Version: ${packageInfo.version}'),
              const SizedBox(height: 8),
              Text('Build Number: ${packageInfo.buildNumber}'),
              const SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error getting package info: $e');
      // Handle error appropriately
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Support Request: Spendulum App',
      },
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    }
  }
}

class _FAQScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFAQItem(
            'How do I add an expense?',
            'Tap the + button on the home screen, select "Expense", fill in the details, and tap "Save".',
          ),
          _buildFAQItem(
            'How do I set up a budget?',
            'Go to Budget tab, tap "Create Budget", select category, set amount and period, then tap "Save".',
          ),
          _buildFAQItem(
            'Can I export my data?',
            'Yes! Go to More > Export and choose your preferred format (CSV or Excel).',
          ),
          // Add more FAQs as needed
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title:
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer),
        ),
      ],
    );
  }
}

class _UserGuideScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGuideSection(
            'Getting Started',
            'Learn the basics of expense tracking',
            Icons.start,
          ),
          _buildGuideSection(
            'Managing Expenses',
            'Track and categorize your spending',
            Icons.money,
          ),
          _buildGuideSection(
            'Budgeting',
            'Set and monitor your budgets',
            Icons.account_balance_wallet,
          ),
          _buildGuideSection(
            'Reports & Analytics',
            'Understand your spending patterns',
            Icons.analytics,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ProblemReportScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a Problem')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Problem Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please describe the problem';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final title = _titleController.text;
                  final description = _descriptionController.text;
                  await _sendEmail(
                      'Problem Report: $title', 'Description:\n$description');
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendEmail(String subject, String body) async {
    try {
      final smtpEmail = await SecureConfig.getSecureValue('SMTP_EMAIL');
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: smtpEmail,
        queryParameters: {
          'subject': subject,
          'body': body,
        },
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrlString(emailLaunchUri.toString());
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}

class _FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<_FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Feedback')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'How would you rate your experience?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: index < _rating ? Colors.amber : null,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Your Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your feedback';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final smtpEmail =
                      await SecureConfig.getSecureValue('SMTP_EMAIL');
                  await EmailUtils.sendEmail(
                    to: smtpEmail.toString(),
                    subject: 'App Feedback',
                    body:
                        'Rating: $_rating/5\n\nFeedback:\n${_feedbackController.text}',
                    context: context,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
