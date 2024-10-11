import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home_screen/company_home_screen.dart';
import '../home_screen/job_seeker_home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          }
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData != null && userData.containsKey('role')) {
                  String userRole = userData['role'];
                  if (userRole == 'company') {
                    return CompanyHomeScreen();
                  } else {
                    return JobSeekerHomeScreen();
                  }
                }
              }
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          );
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}


