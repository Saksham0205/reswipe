import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/company_model/applications.dart';
import 'profile_image.dart';
import 'skill_chip.dart';

class FavoriteCardContent extends StatelessWidget {
  final Application application;
  final VoidCallback onTap;

  const FavoriteCardContent({
    Key? key,
    required this.application,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.deepPurple.shade50.withOpacity(0.3),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildBody(),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Row(
        children: [
          ProfileImage(application: application),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.applicantName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  application.jobProfile,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
              ],
            ),
          ),
          _buildMatchBadge(),
        ],
      ),
    );
  }

  Widget _buildMatchBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16.sp, color: Colors.green.shade700),
          SizedBox(width: 4.w),
          Text(
            'Matched',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.school, application.qualification),
          SizedBox(height: 8.h),
          _buildInfoRow(Icons.location_on, application.college),
          SizedBox(height: 12.h),
          _buildSkills(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: Colors.deepPurple.shade700,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
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
      children: application.skills.map((skill) => SkillChip(label: skill)).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            icon: Icons.description,
            label: 'View Resume',
            onPressed: () => _handleResumeView(context),
          ),
          _buildActionButton(
            context,
            icon: Icons.info_outline,
            label: 'Details',
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onPressed,
      }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18.sp),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.deepPurple.shade700,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
    );
  }

  void _handleResumeView(BuildContext context) {
    if (application.resumeUrl.isNotEmpty) {
      launchUrl(Uri.parse(application.resumeUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resume not available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}