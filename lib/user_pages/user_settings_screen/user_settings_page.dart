import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reswipe/user_pages/user_settings_screen/about_screen.dart';
import 'package:reswipe/user_pages/user_settings_screen/privacy_and_security_screen.dart';
import 'package:reswipe/user_pages/user_settings_screen/support_and_help_screen.dart';





class UserSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 16.0),
              SettingsCard(
                icon: Icons.manage_accounts,
                title: 'Manage Account Settings',
                onTap: () {
                  // Navigate to account settings
                },
              ),
              const SizedBox(height: 16.0),
              SettingsCard(
                icon: Icons.payment,
                title: 'Manage Payment',
                onTap: () {
                  // Navigate to payment settings
                },
              ),
              const SizedBox(height: 32.0),
              Text(
                'Security & Privacy',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 16.0),
              SettingsCard(
                icon: Icons.lock,
                title: 'Privacy & Security',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyAndSecurityScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              SettingsCard(
                icon: Icons.help,
                title: 'Support & Help',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpAndSupportScreen()),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              SettingsCard(
                icon: Icons.people,
                title: 'About Us',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (contex)=>const AboutScreen()));
                },
              ),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // Navigate to login screen
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 32.0,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}