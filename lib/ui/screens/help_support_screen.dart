import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          _buildSection(
            context,
            icon: Icons.menu_book,
            title: 'User Guide',
            subtitle: 'Learn how to use the app effectively',
            onTap: () => _showUserGuideScreen(context),
          ),
          _buildSection(
            context,
            icon: Icons.contact_support,
            title: 'Contact Support',
            subtitle: 'Get in touch with our support team',
            onTap: () => _showContactSupport(context),
          ),
          _buildSection(
            context,
            icon: Icons.bug_report,
            title: 'Report a Problem',
            subtitle: 'Let us know if something isn\'t working',
            onTap: () => _showReportProblem(context),
          ),
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
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _showVersionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('App Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Build Number: 100'),
            SizedBox(height: 16),
            Text('Last Updated: November 8, 2024'),
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
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // Submit problem report
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
}

class _FeedbackScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

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
                  icon: Icon(Icons.star_border),
                  onPressed: () {
                    // Handle rating
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
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // Submit feedback
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
