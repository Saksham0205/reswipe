import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../models/company_model/applications.dart';

class ProfileImage extends StatelessWidget {
  final Application application;
  final String? heroSuffix;

  const ProfileImage({
    Key? key,
    required this.application,
    this.heroSuffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final heroTag = 'profile_${application.id}${heroSuffix ?? ""}';

    return Hero(
      tag: heroTag,
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade500],
          ),
        ),
        child: Center(
          child: Text(
            application.applicantName[0].toUpperCase(),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}