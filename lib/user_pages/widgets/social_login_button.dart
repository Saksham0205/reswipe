import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleSignIn;

  const SocialLoginButtons({
    Key? key,
    required this.isLoading,
    required this.onGoogleSignIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Image.asset('assets/google_icon.png'),
      label: const Text('Sign in with Google'),
      onPressed: isLoading ? null : onGoogleSignIn,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Colors.black54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

class SignUpPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const SignUpPrompt({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "New to Reswipe?",
          style: TextStyle(color: Colors.black54),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            'Join now',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}