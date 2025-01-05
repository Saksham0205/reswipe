import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state_management/company_state.dart';
import '../home_screen/screens/company_home_screen.dart';
import '../home_screen/screens/job_seeker_home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

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
                    // Create a new JobBloc for company users
                    return BlocProvider(
                      create: (context) => JobBloc(
                        firestore: FirebaseFirestore.instance,
                        messaging: FirebaseMessaging.instance,
                      )..add(LoadJobs()), // Initialize by loading jobs
                      child: const CompanyMainScreen(),
                    );
                  } else {
                    return JobSeekerHomeScreen();
                  }
                }
              }
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}