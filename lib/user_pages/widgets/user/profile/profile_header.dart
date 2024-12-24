import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../controller/profile_controller.dart';
import '../../shared/profile_text_field.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileController controller;

  const ProfileHeader({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImage(context),
            SizedBox(width: 16.w),
            Expanded(child: _buildPersonalInfo()),
          ],
        ),
        if (controller.hasUnsavedChanges)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => controller.discardChanges(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Discard Changes'),
                ),
                SizedBox(width: 16.w),
                ElevatedButton(
                  onPressed: () => controller.saveChanges(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: controller.isImageLoading ? null : () => controller.uploadProfileImage(context),
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepPurple, width: 3.w),
                ),
                child: controller.isImageLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CircleAvatar(
                  radius: 58.r,
                  backgroundImage: controller.profileData.profileImageUrl.isNotEmpty
                      ? NetworkImage(controller.profileData.profileImageUrl)
                      : null,
                  child: controller.profileData.profileImageUrl.isEmpty
                      ? Icon(Icons.person, size: 60.sp)
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 18.sp),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildLikesCounter(),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileTextField(
          controller: controller.nameController,
          labelText: 'Full Name',
          icon: Icons.person,
        ),
        SizedBox(height: 8.h),
        ProfileTextField(
          controller: controller.emailController,
          labelText: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 8.h),
        ProfileTextField(
          controller: controller.collegeController,
          labelText: 'College',
          icon: Icons.school,
        ),
        SizedBox(height: 8.h),
        ProfileTextField(
          controller: controller.collegeSessionController,
          labelText: 'College Session (YYYY-YYYY)',
          icon: Icons.date_range,
          keyboardType: TextInputType.datetime,
        ),
      ],
    );
  }

  Widget _buildLikesCounter() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, color: Colors.deepPurple, size: 20.sp),
              SizedBox(width: 4.w),
              Text(
                'Company Likes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '${controller.profileData.companyLikesCount}',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Text(
            'Total Likes',
            style: TextStyle(fontSize: 12.sp, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}
