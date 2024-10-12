import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userStream => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
  }

// Add sign in, sign up methods as needed
}