import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.deepPurple.shade200, width: 1.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.deepPurple.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}