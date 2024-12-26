import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reswipe/company_pages/home_screen/favourites/components/profile_image.dart';
import '../../../../models/company_model/applications.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailsSheet extends StatelessWidget {
  final Application application;

  const ApplicationDetailsSheet({
    Key? key,
    required this.application,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              _buildDragHandle(),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24.h),
                    if (application.experience.isNotEmpty)
                      _buildSection('Experience', application.experience),
                    _buildSection('Education', [
                      application.qualification,
                      'College: ${application.college}',
                    ]),
                    if (application.skills.isNotEmpty)
                      _buildSection('Skills', application.skills),
                    if (application.projects.isNotEmpty)
                      _buildSection('Projects', application.projects),
                    if (application.achievements.isNotEmpty)
                      _buildSection('Achievements', application.achievements),
                    SizedBox(height: 24.h),
                    _buildResumeButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                application.jobProfile,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: Colors.deepPurple, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildResumeButton(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          if (application.resumeUrl.isNotEmpty) {
            launchUrl(Uri.parse(application.resumeUrl));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resume not available'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        icon: Icon(Icons.description, size: 18.sp),
        label: Text('View Resume', style: TextStyle(fontSize: 16.sp)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.deepPurple,
          side: BorderSide(color: Colors.deepPurple.shade200),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        ),
      ),
    );
  }
}