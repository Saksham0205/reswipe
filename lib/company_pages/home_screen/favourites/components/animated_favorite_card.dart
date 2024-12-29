import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../models/company_model/applications.dart';

class AnimatedFavoriteCard extends StatelessWidget {
  final Application application;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AnimatedFavoriteCard({
    Key? key,
    required this.application,
    required this.index,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              _buildDetails(),
              SizedBox(height: 12.h),
              _buildSkills(),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                application.applicantName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                application.jobTitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, size: 20.sp),
          onPressed: onDelete,
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        _buildInfoRow(Icons.school, application.qualification),
        SizedBox(height: 8.h),
        _buildInfoRow(Icons.work, application.jobProfile),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkills() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: application.skills.take(3).map((skill) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.3),
          ),
        ),
        child: Text(
          skill,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.deepPurple,
          ),
        ),
      )).toList(),
    );
  }
}