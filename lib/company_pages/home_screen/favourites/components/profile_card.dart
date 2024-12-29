import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/company_model/applications.dart';

class ProfileCard extends StatelessWidget {
  final Application application;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onViewResume;

  const ProfileCard({
    Key? key,
    required this.application,
    required this.index,
    required this.onDelete,
    required this.onViewResume,
  }) : super(key: key);

  @override
  void _viewResume(BuildContext context) {
    if (application.resumeUrl.isNotEmpty) {
      launchUrl(Uri.parse(application.resumeUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Resume not available',
            style: TextStyle(fontSize: 14.sp),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _showFullProfile(context),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              _buildDetails(),
              SizedBox(height: 12.h),
              _buildActions(context),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              application.applicantName[0].toUpperCase(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                application.applicantName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                application.college ?? 'College not specified',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, size: 18.sp),
          onPressed: onDelete,
          color: Colors.grey[400],
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: 24.w,
            minHeight: 24.w,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return SingleChildScrollView(  // Allow horizontal scrolling if needed
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,  // Take minimum space needed
        children: [
          _buildDetailItem(
            icon: Icons.school,
            label: application.qualification,
          ),
          SizedBox(width: 46.w),
          _buildDetailItem(
            icon: Icons.calendar_today,
            label: application.collegeSession ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120.w),  // Limit maximum width
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: Colors.grey[600],
          ),
          SizedBox(width: 4.w),
          Flexible(  // Allow text to wrap if needed
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,  // Add ellipsis for long text
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _viewResume(context),  // This passes a callback function,
            icon: Icon(
              Icons.description_outlined,
              size: 16.sp,
            ),
            label: const Text('Resume'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              side: const BorderSide(color: Colors.deepPurple),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailedProfileSheet(application: application),
    );
  }
}

class _DetailedProfileSheet extends StatelessWidget {
  final Application application;

  const _DetailedProfileSheet({
    Key? key,
    required this.application,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Skills', application.skills),
                  SizedBox(height: 24.h),
                  _buildSection('Experience', application.experience),
                  SizedBox(height: 24.h),
                  _buildSection('Projects', application.projects),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        SizedBox(height: 12.h),
        ...items.map((item) => _buildListItem(item)),
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
