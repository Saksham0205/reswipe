import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'About Reswipe',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18.sp),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Purple Header Section
            Container(
              color: Colors.deepPurpleAccent,
              padding: EdgeInsets.all(20.w),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10.r,
                            spreadRadius: 1.r,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.document_scanner_outlined,
                        size: 50.r,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Reswipe v1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Simplifying Resume Screening',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Sections
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('About Reswipe'),
                  SizedBox(height: 10.h),
                  _buildSectionContent(
                    'Reswipe is an innovative application designed to simplify resume screening, bringing speed and precision to the job recruitment process. Built under Ajnabee, Reswipe leverages smart algorithms to quickly identify suitable candidates by swiping through resumes.',
                  ),
                  SizedBox(height: 25.h),
                  _buildSectionTitle('Key Features'),
                  SizedBox(height: 10.h),
                  _buildFeatureItem(Icons.speed, 'Quick Screening', 'Screen resumes with simple swipe gestures'),
                  _buildFeatureItem(Icons.psychology, 'Smart Matching', 'AI-powered candidate matching algorithms'),
                  _buildFeatureItem(Icons.analytics, 'Analytics', 'Detailed insights and screening metrics'),
                  _buildFeatureItem(Icons.cloud_sync, 'Cloud Sync', 'Access your data across devices'),
                  SizedBox(height: 25.h),
                  _buildSectionTitle('About Ajnabee'),
                  SizedBox(height: 10.h),
                  _buildSectionContent(
                    'Ajnabee, the parent company of Reswipe, focuses on cutting-edge digital solutions in recruitment, fashion, and technology. Through Ajnabee, we aim to provide smart, user-friendly apps to solve real-world challenges.',
                  ),
                  SizedBox(height: 25.h),
                  _buildSectionTitle('Contact Us'),
                  SizedBox(height: 10.h),
                  _buildContactItem(Icons.email, 'ajnabee.care@gmail.com', 'mailto:ajnabee.care@gmail.com'),
                  _buildContactItem(Icons.language, 'www.ajnabee.in', 'https://www.ajnabee.in'),
                  _buildContactItem(Icons.location_on, 'New Delhi, India', ''),
                  SizedBox(height: 30.h),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Powered by Ajnabee',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          '© 2024 All rights reserved',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurpleAccent,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16.sp,
        height: 1.5.h,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: Colors.deepPurpleAccent,
              size: 24.r,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, String url) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: GestureDetector(
        onTap: () => url.isNotEmpty ? _launchURL(url) : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.deepPurpleAccent,
              size: 20.r,
            ),
            SizedBox(width: 15.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
