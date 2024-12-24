import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../models/company_model/applications.dart';

class FirstPage extends StatelessWidget {
  final Application application;
  final VoidCallback onResumeView;
  final VoidCallback onDetailsPressed;

  const FirstPage({
    Key? key,
    required this.application,
    required this.onResumeView,
    required this.onDetailsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(child: _buildSkillsSection()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.0.w), // Responsive padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            application.applicantName,
            style: TextStyle(
              fontSize: 32.sp, // Responsive font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h), // Responsive spacing
          Text(
            application.qualification,
            style: TextStyle(
              fontSize: 24.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            application.college,
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      padding: EdgeInsets.all(24.0.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade600,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.w, // Responsive spacing
                runSpacing: 8.h,
                children: application.skills.map(_buildSkillChip).toList(),
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.deepPurple.shade200,
          width: 1.w,
        ),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: Colors.deepPurple.shade700,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 150.w, // Responsive width
          child: ElevatedButton.icon(
            onPressed: onResumeView,
            icon: Icon(Icons.description, color: Colors.white, size: 18.sp),
            label: Text(
              'Resume',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onDetailsPressed,
          icon: Icon(Icons.info_outline, size: 24.sp),
          color: Colors.deepPurple,
          tooltip: 'View Details',
        ),
      ],
    );
  }
}
