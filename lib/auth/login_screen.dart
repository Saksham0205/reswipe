import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_text_styles.dart';
import '../services/firestore_service.dart';
import '../user_pages/widgets/animated_controller.dart';
import '../user_pages/widgets/login_form.dart';
import '../user_pages/widgets/social_login_button.dart';
import 'forgot_password.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  Future<void> _handleGoogleSignIn() async {
    _setLoading(true);
    try {
      final UserCredential? userCredential = await _authService.signInWithGoogle();
      if (userCredential == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign in was cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in with Google: $e')),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransitionContainer(
          animation: _animationController,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   SizedBox(height: 20.h),
                  Lottie.asset(
                    'assets/lottie/job_lottie.json',
                    height: 200.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    'Sign in',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Stay updated on your professional world',
                    style: AppTextStyles.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.h),
                  LoginForm(
                    isLoading: _isLoading,
                    onLoadingChanged: _setLoading,
                    onForgotPassword: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  const DividerWithText(text: 'or'),
                  SizedBox(height: 20.h),
                  SocialLoginButtons(
                    isLoading: _isLoading,
                    onGoogleSignIn: _handleGoogleSignIn,
                  ),
                  SizedBox(height: 20.h),
                  SignUpPrompt(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => RegistrationScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}