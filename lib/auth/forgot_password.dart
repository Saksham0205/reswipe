import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

        setState(() => _emailSent = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred';

        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found with this email address.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again later.';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Lottie.asset(
                  'assets/lottie/forgot_password_lottie.json',
                  height: 200.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 40.h),
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Enter your email address and we\'ll send you instructions to reset your password.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                if (!_emailSent) ...[
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: Icon(Icons.email_outlined, size: 24.r),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.deepPurple[700]!, width: 2.w),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple[700],
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: const Text('Send Reset Link'),
                  ),
                ] else ...[
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 64.r,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Check your email',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'We\'ve sent password reset instructions to:\n${_emailController.text}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _emailSent = false;
                        _emailController.clear();
                      });
                    },
                    child: Text(
                      'Try a different email',
                      style: TextStyle(
                        color: Colors.deepPurple[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Remember your password? ",
                      style: TextStyle(color: Colors.black54, fontSize: 14.sp),
                    ),
                    TextButton(
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.deepPurple[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
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
    );
  }
}
