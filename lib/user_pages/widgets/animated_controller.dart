import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FadeTransitionContainer extends StatelessWidget {
  final AnimationController animation;
  final Widget child;

  const FadeTransitionContainer({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      ),
      child: child,
    );
  }
}

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(text, style: const TextStyle(color: Colors.black54)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}