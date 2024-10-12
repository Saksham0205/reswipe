import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  String _role = 'job_seeker';
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        String? companyId;
        if (_role == 'company') {
          companyId = _generateRandomCompanyId();
        }

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': _name,
          'role': _role,
          'email': _email,
          if (companyId != null) 'companyId': companyId,
        });

        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: ${e.message}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String _generateRandomCompanyId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
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
                    'assets/lottie/job_registration_lottie.json',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Join our professional community',
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
                          hintText: 'Full Name',
                          onSaved: (value) => _name = value!,
                        ),
                        SizedBox(height: 16),
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
                        _buildRoleDropdown(),
                        SizedBox(height: 24),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                          child: Text('Register'),
                          onPressed: _register,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?", style: TextStyle(color: Colors.black54)),
                      TextButton(
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _role,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey[500]!),

        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: [
        DropdownMenuItem(child: Text('Job Seeker'), value: 'job_seeker'),
        DropdownMenuItem(child: Text('Company'), value: 'company'),
      ],
      onChanged: (value) => setState(() => _role = value!),
      validator: (value) => value == null ? 'Please select a role' : null,
    );
  }
}