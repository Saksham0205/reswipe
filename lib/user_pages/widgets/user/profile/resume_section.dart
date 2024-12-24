import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../controller/profile_controller.dart';

class ResumeSection extends StatelessWidget {
  final ProfileController controller;

  const ResumeSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resume',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 16.h),
            _buildUploadArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(
            controller.profileData.resumeUrl.isEmpty ? Icons.upload_file : Icons.description,
            size: 48.r,
            color: Colors.deepPurple,
          ),
          SizedBox(height: 8.h),
          Text(
            controller.profileData.resumeUrl.isEmpty
                ? 'Upload your resume (PDF)'
                : 'Resume uploaded successfully',
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),
          if (controller.isParsingResume)
            const CircularProgressIndicator(color: Colors.deepPurple)
          else
            ElevatedButton.icon(
              onPressed: controller.isLoading
                  ? null
                  : () => controller.uploadAndParseResume(context),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: Text(
                controller.profileData.resumeUrl.isEmpty ? 'Select File' : 'Update Resume',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
        ],
      ),
    );
  }
}