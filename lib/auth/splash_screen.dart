import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home_screen/screens/job_seeker_home_screen.dart';
import 'login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAppropriateScreen();
  }

  Future<void> _navigateToAppropriateScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const JobSeekerHomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("ReSwipe",style: TextStyle(fontSize: 80,fontWeight: FontWeight.bold,color: Colors.deepPurple),)),
    );
  }
}