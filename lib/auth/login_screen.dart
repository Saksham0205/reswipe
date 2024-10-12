import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _tryLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        // Navigation will be handled by AuthWrapper
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in: ${e.message}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Lottie.asset(
                    'assets/lottie/job_lottie.json',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Stay updated on your professional world',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          hintText: 'Email',
                          onSaved: (value) => _email = value!,
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          hintText: 'Password',
                          obscureText: true,
                          onSaved: (value) => _password = value!,
                        ),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              // Handle forgot password
                            },
                          ),
                        ),
                        SizedBox(height: 24),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(

                          child: Text('Sign in'),
                          onPressed: _tryLogin,
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size.fromWidth(150),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue[700],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or', style: TextStyle(color: Colors.black54)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 20),
                  OutlinedButton.icon(
                    icon: Icon(Icons.android, color: Colors.green),
                    label: Text('Sign in with Google'),
                    onPressed: () {
                      // Handle Google Sign-In
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.black54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("New to JobFinder?", style: TextStyle(color: Colors.black54)),
                      TextButton(
                        child: Text(
                          'Join now',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RegistrationScreen(),
                          ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    bool obscureText = false,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      obscureText: obscureText,
      onSaved: onSaved,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }
}