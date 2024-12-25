import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reswipe/home_screen/company_home_screen.dart';

import '../home_screen/job_seeker_home_screen.dart';
import 'login_screen.dart';

class CompanyVerificationScreen extends StatefulWidget {
  final String email;
  final String companyName;

  CompanyVerificationScreen({required this.email, required this.companyName});

  @override
  _CompanyVerificationScreenState createState() => _CompanyVerificationScreenState();
}

class _CompanyVerificationScreenState extends State<CompanyVerificationScreen> {
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  void _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'emailVerified': true, 'isVerified': true});

        // Use AuthWrapper for navigation after verification
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AuthWrapper(),
        ));
      } else {
        Future.delayed(const Duration(seconds: 5), _checkEmailVerification);
      }
    }
  }

  void _resendVerificationEmail() async {
    setState(() => _isVerifying = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email resent to ${widget.email}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend verification email: $e')),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Verification'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify Your Company Email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'A verification email has been sent to your company email address. Please check your inbox and click on the verification link.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text('Company: ${widget.companyName}', style: const TextStyle(fontSize: 18)),
            Text('Email: ${widget.email}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            Center(
              child: _isVerifying
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple[700],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Resend Verification Email'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                  bool isVerified = userData['isVerified'] ?? false;
                  bool isEmailVerified = userData['emailVerified'] ?? false;

                  if (userRole == 'company') {
                    if (!isEmailVerified) {
                      return CompanyVerificationScreen(
                        email: userData['email'],
                        companyName: userData['companyName'],
                      );
                    } else if (isVerified) {
                      return CompanyMainScreen();
                    } else {
                      // Company is email verified but not fully verified
                      // You might want to create a separate screen for this state
                      return const Scaffold(body: Center(child: Text('Waiting for company verification')));
                    }
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