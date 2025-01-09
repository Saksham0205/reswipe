import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state_management/company_backend.dart';
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
          return FutureBuilder<List<dynamic>>(
            future: Future.wait([
              FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              SharedPreferences.getInstance(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userDoc = snapshot.data![0] as DocumentSnapshot;
                final prefs = snapshot.data![1] as SharedPreferences;

                Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

                if (userData != null && userData.containsKey('role')) {
                  String userRole = userData['role'];
                  if (userRole == 'company') {
                    return BlocProvider(
                      create: (context) => JobBloc(
                        prefs: prefs,
                        firestore: FirebaseFirestore.instance,
                        messaging: FirebaseMessaging.instance,
                      )..add(LoadJobs()),
                      child: const CompanyMainScreen(),
                    );
                  } else {
                    return JobSeekerHomeScreen();
                  }
                }
              } else if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}