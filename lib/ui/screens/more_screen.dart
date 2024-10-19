import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/theme_provider.dart';
import 'package:spendulum/ui/screens/theme_selection_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Use a gradient background for a more aesthetic look
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade100, Colors.purple.shade100],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('More Options',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildListItem(
              context,
              icon: Icons.palette,
              title: 'Theme',
              subtitle: 'Customize app appearance',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThemeSelectionScreen()),
              ),
            ),
            _buildListItem(
              context,
              icon: Icons.category,
              title: 'Categories',
              subtitle: 'Manage expense categories',
              onTap: () {
                // TODO: Navigate to Categories management screen
              },
            ),
            _buildListItem(
              context,
              icon: Icons.bar_chart,
              title: 'Reports',
              subtitle: 'View detailed expense reports',
              onTap: () {
                // TODO: Navigate to Reports screen
              },
            ),
            _buildListItem(
              context,
              icon: Icons.notifications,
              title: 'Reminders',
              subtitle: 'Set up expense reminders',
              onTap: () {
                // TODO: Navigate to Reminders setup screen
              },
            ),
            _buildListItem(
              context,
              icon: Icons.security,
              title: 'Security',
              subtitle: 'Manage app security settings',
              onTap: () {
                // TODO: Navigate to Security settings screen
              },
            ),
            _buildListItem(
              context,
              icon: Icons.cloud_upload,
              title: 'Backup & Sync',
              subtitle: 'Manage data backup and synchronization',
              onTap: () {
                // TODO: Navigate to Backup & Sync screen
              },
            ),
            _buildListItem(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get assistance and view FAQs',
              onTap: () {
                // TODO: Navigate to Help & Support screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
