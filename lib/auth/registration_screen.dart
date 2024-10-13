import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'company_verification_screen.dart';
import '../models/user_registration.dart';  // Import the new UserRegistration model

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  String _role = 'job_seeker';
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await userCredential.user!.sendEmailVerification();

        String? companyId;
        if (_role == 'company') {
          companyId = _generateRandomCompanyId();
        }

        UserRegistration newUser = UserRegistration(
          name: _nameController.text,
          email: _emailController.text,
          role: _role,
          companyName: _role == 'company' ? _companyNameController.text : null,
          companyId: companyId,
        );

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(newUser.toMap());

        if (_role == 'company') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => CompanyVerificationScreen(email: _emailController.text, companyName: _companyNameController.text),
          ));
        } else {
          // For job seekers, we'll let AuthWrapper handle the navigation
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => AuthWrapper(),
          ));
        }
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Lottie.asset(
                    'assets/lottie/job_registration_lottie.json',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Join our professional community',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Full Name',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        _buildRoleDropdown(),
                        const SizedBox(height: 16),
                        if (_role == 'company')
                          _buildTextField(
                            controller: _companyNameController,
                            hintText: 'Company Name',
                          ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size.fromWidth(150),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?", style: TextStyle(color: Colors.black54)),
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
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: const [
        DropdownMenuItem(value: 'job_seeker', child: Text('Job Seeker')),
        DropdownMenuItem(value: 'company', child: Text('Company')),
      ],
      onChanged: (value) => setState(() => _role = value!),
      validator: (value) => value == null ? 'Please select a role' : null,
    );
  }
}