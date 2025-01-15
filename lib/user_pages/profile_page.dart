import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reswipe/user_pages/widgets/user/profile/professional_section.dart';
import 'package:reswipe/user_pages/widgets/user/profile/profile_header.dart';
import 'package:reswipe/user_pages/widgets/user/profile/resume_section.dart';
import 'package:reswipe/user_pages/widgets/user/profile/skills_achievements_section.dart';

import '../controller/profile_controller.dart';



class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _controller = ProfileController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.loadUserProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Professional Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _controller.shareProfile(context),
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: RefreshIndicator(
          onRefresh: _controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.r),
                      bottomRight: Radius.circular(30.r),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeader(controller: _controller),
                      SizedBox(height: 24.h),
                      if (_controller.isParsingResume)
                        Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16.h),
                              const Text('Extracting data from resume...'),
                            ],
                          ),
                        ),
                      ResumeSection(controller: _controller),
                      SizedBox(height: 24.h),
                      ProfessionalSection(controller: _controller),
                      SizedBox(height: 24.h),
                      SkillsAchievementsSection(controller: _controller),
                      SizedBox(height: 32.h),
                      _buildUpdateButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _controller.isLoading ? 50 : 200,
        height: 50.h,
        child: ElevatedButton(
          onPressed: _controller.isLoading
              ? null
              : () {
            if (_formKey.currentState?.validate() ?? false) {
              _controller.updateProfile(context, showSnackBar: true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
            ),
            elevation: 5,
            shadowColor: Colors.deepPurple.withOpacity(0.5),
          ),
          child: _controller.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              :  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save, color: Colors.white),
              SizedBox(width: 8.w),
              Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}