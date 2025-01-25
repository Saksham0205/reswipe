import 'dart:math';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'company_verification_screen.dart';
import '../models/user_registration.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  String _role = 'job_seeker';
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Get FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Create user account
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Generate company ID if needed
      String? companyId = _role == 'company' ? _generateRandomCompanyId() : null;

      // Create user profile with FCM token
      UserRegistration newUser = UserRegistration(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _role,
        companyName: _role == 'company' ? _companyNameController.text.trim() : null,
        companyId: companyId,
        fcmToken: fcmToken, // Add FCM token here
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      // Navigate based on role
      if (_role == 'company') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => CompanyVerificationScreen(
            email: _emailController.text.trim(),
            companyName: _companyNameController.text.trim(),
          ),
        ));
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.message ?? 'Registration failed');
    } catch (e) {
      _showErrorSnackbar('An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _generateRandomCompanyId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random.secure();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[50]!,
                  Colors.grey[100]!,
                ],
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(24.0.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    _buildHeader(),
                    SizedBox(height: 30.h),
                    _buildRegistrationCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          child: Lottie.asset(
            'assets/lottie/job_registration_lottie.json',
            height: 120.h,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 20.h),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.deepPurple[700]!, Colors.deepPurple[900]!],
          ).createShader(bounds),
          child: Text(
            'Join Reswipe',
            style: GoogleFonts.poppins(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          'Where talent meets opportunity',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 20.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.all(24.0.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRoleSelector(),
                  SizedBox(height: 24.h),
                  ..._buildFormFields(),
                  SizedBox(height: 32.h),
                  _buildRegisterButton(),
                  SizedBox(height: 16.h),
                  _buildSignInLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  String? Function(String?) _getValidator(String label) {
    switch (label) {
      case 'Full Name':
        return (value) {
          if (value?.isEmpty ?? true) return 'Name is required';
          if (value!.length < 2) return 'Name is too short';
          return null;
        };
      case 'Email':
        return (value) {
          if (value?.isEmpty ?? true) return 'Email is required';
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
            return 'Enter a valid email';
          }
          return null;
        };
      case 'Password':
        return (value) {
          if (value?.isEmpty ?? true) return 'Password is required';
          if (value!.length < 6) return 'Password must be at least 6 characters';
          return null;
        };
      case 'Company Name':
        return (value) {
          if (value?.isEmpty ?? true) return 'Company name is required';
          return null;
        };
      default:
        return (value) => null;
    }
  }

  Widget _buildSignInLink() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Sign In',
              style: TextStyle(
                color: Colors.deepPurple[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  List<Widget> _buildFormFields() {
    return [
      _buildAnimatedTextField(
        controller: _nameController,
        label: 'Full Name',
        icon: Icons.person_outline,
        delay: 0.1,
      ),
      SizedBox(height: 16.h),
      _buildAnimatedTextField(
        controller: _emailController,
        label: 'Email',
        icon: Icons.email_outlined,
        delay: 0.2,
      ),
      SizedBox(height: 16.h),
      _buildAnimatedTextField(
        controller: _passwordController,
        label: 'Password',
        icon: Icons.lock_outline,
        isPassword: true,
        delay: 0.3,
      ),
      if (_role == 'company') ...[
        SizedBox(height: 16.h),
        _buildAnimatedTextField(
          controller: _companyNameController,
          label: 'Company Name',
          icon: Icons.business_outlined,
          delay: 0.4,
        ),
      ],
    ];
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double delay,
    bool isPassword = false,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, delay + 0.2, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, delay + 0.2, curve: Curves.easeOut),
          ),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          style: TextStyle(fontSize: 16.sp),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.deepPurple[700]),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.deepPurple[700],
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.deepPurple[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.deepPurple[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.deepPurple[700]!, width: 2.w),
            ),
            filled: true,
            fillColor: Colors.deepPurple[50],
            labelStyle: TextStyle(color: Colors.deepPurple[700]),
          ),
          validator: _getValidator(label),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _buildRoleOption('job_seeker', 'Job Seeker', Icons.person_search, 0.0),
          _buildRoleOption('company', 'Company', Icons.business, 0.1),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String value, String label, IconData icon, double delay) {
    final isSelected = _role == value;
    return Expanded(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, delay + 0.2, curve: Curves.easeOut),
          ),
        ),
        child: GestureDetector(
          onTap: () => setState(() => _role = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple[700] : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8.r,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.deepPurple[700],
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.deepPurple[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.6, 0.8, curve: Curves.easeOut),
        ),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple[700],
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? SizedBox(
          height: 20.h,
          width: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          'Create Account',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}