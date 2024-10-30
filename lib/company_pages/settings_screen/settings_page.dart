import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanySettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notification Settings'),
          onTap: () {
            // Navigate to notification settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Privacy Settings'),
          onTap: () {
            // Navigate to privacy settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          onTap: () {
            // Navigate to help & support
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () {
            // Show about dialog
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Logout'),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            // Navigate to login screen
          },
        ),
      ],
    );
  }
}