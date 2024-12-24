import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0.h,
            floating: false,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.deepPurple.shade700,
                      Colors.deepPurple.shade500,
                    ],
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15.r,
                              spreadRadius: 2.r,
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'app_icon',
                          child: Icon(
                            Icons.document_scanner_outlined,
                            size: 60.sp,
                            color: Colors.deepPurple.shade600,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Reswipe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.w),
                        ),
                        child: Text(
                          'Simplifying Resume Screening',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(
                      title: 'About Reswipe',
                      content: 'Reswipe is an innovative application designed to simplify resume screening, bringing speed and precision to the job recruitment process. Built under Ajnabee, Reswipe leverages smart algorithms to quickly identify suitable candidates by swiping through resumes.',
                      icon: Icons.info_outline,
                    ),
                    SizedBox(height: 20.h),
                    _buildFeaturesList(),
                    SizedBox(height: 20.h),
                    _buildCard(
                      title: 'About Ajnabee',
                      content: 'Ajnabee, the parent company of Reswipe, focuses on cutting-edge digital solutions in recruitment, fashion, and technology. Through Ajnabee, we aim to provide smart, user-friendly apps to solve real-world challenges.',
                      icon: Icons.business_outlined,
                    ),
                    SizedBox(height: 20.h),
                    _buildContactSection(),
                    SizedBox(height: 30.h),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Icon(icon, color: Colors.deepPurple),
              ),
              SizedBox(width: 15.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.speed,
        'title': 'Quick Screening',
        'description': 'Screen resumes with simple swipe gestures',
      },
      {
        'icon': Icons.psychology,
        'title': 'Smart Matching',
        'description': 'AI-powered candidate matching algorithms',
      },
      {
        'icon': Icons.analytics,
        'title': 'Analytics',
        'description': 'Detailed insights and screening metrics',
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Cloud Sync',
        'description': 'Access your data across devices',
      },
    ];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_outline, color: Colors.deepPurple),
              SizedBox(width: 15.w),
              Text(
                'Key Features',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...features.map((feature) => _buildFeatureItem(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            description: feature['description'] as String,
          )),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 24.sp),
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
                SizedBox(height: 4.h),
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

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_support_outlined, color: Colors.deepPurple, size: 24.sp),
              SizedBox(width: 15.w),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildContactItem(
            icon: Icons.email_outlined,
            text: 'ajnabee.care@gmail.com',
            onTap: () => _launchUrl(Uri.parse('mailto:ajnabee.care@gmail.com')),
          ),
          _buildContactItem(
            icon: Icons.language,
            text: 'www.ajnabee.in',
            onTap: () => _launchUrl(Uri.parse('https://www.ajnabee.in/')),
          ),
          _buildContactItem(
            icon: Icons.location_on_outlined,
            text: 'New Delhi, India',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 24.sp),
            SizedBox(width: 15.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: onTap != null ? Colors.deepPurple : Colors.black87,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFooter() {
    return  Center(
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
    );
  }
}