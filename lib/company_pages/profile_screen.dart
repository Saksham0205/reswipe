import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profile information goes here'),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Sign Out'),
              onPressed: () => AuthService().signOut(),
            ),
          ],
        ),
      ),
    );
  }
}