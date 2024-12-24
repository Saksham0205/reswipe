import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpandableTextField extends StatelessWidget {
  final String title;
  final IconData icon;
  final String initialValue;
  final Function(String) onChanged;
  final String hint;

  const ExpandableTextField({
    Key? key,
    required this.title,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
    required this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          initialValue: initialValue,
          maxLines: null,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            contentPadding: EdgeInsets.all(16.w),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}