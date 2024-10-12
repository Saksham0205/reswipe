import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reswipe/home_screen/company_home_screen.dart';
import 'auth/auth_wrapper.dart';
import 'auth/login_screen.dart';
import 'home_screen/job_seeker_home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(JobFinderApp());
}

class JobFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Job Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/company_home': (context) => CompanyMainScreen(),
        '/job_seeker_home': (context) => JobSeekerHomeScreen(),
      },
    );
  }
}

