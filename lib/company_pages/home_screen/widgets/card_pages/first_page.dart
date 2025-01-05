import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../models/company_model/applications.dart';

class FirstPage extends StatelessWidget {
  final Application application;
  final VoidCallback onResumeView;
  final VoidCallback onDetailsPressed;

  const FirstPage({
    super.key,
    required this.application,
    required this.onResumeView,
    required this.onDetailsPressed,
  });

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
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            application.applicantName,
            style: TextStyle(
              fontSize: 20.sp, // Reduced from 24.sp
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            application.qualification,
            style: TextStyle(
              fontSize: 15.sp, // Reduced from 18.sp
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          ...[
          SizedBox(height: 2.h),
          Text(
            application.college,
            style: TextStyle(
              fontSize: 13.sp, // Reduced from 16.sp
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Skills & Expertise'),
          SizedBox(height: 8.h),
          Expanded(
            child: _buildSkillsGrid(),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade600,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsGrid() {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: application.skills.map(_buildSkillChip).toList(),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.deepPurple.shade100,
          width: 1,
        ),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: Colors.deepPurple.shade700,
          fontSize: 13.sp, // Reduced from 16.sp
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onResumeView,
              icon: Icon(Icons.description, size: 16.sp),
              label: Text(
                'View Resume',
                style: TextStyle(fontSize: 13.sp),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: BorderSide(color: Colors.deepPurple.shade300),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          IconButton(
            onPressed: onDetailsPressed,
            icon: Icon(Icons.info_outline, size: 20.sp),
            color: Colors.deepPurple,
            tooltip: 'More Details',
          ),
        ],
      ),
    );
  }
}