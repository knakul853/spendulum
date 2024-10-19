import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/theme_provider.dart';
import 'package:spendulum/ui/screens/theme_selection_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('More')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThemeSelectionScreen()),
              );
            },
          ),
          // Add other options here
        ],
      ),
    );
  }
}
