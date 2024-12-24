import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyAndSecurityScreen extends StatelessWidget {
  const PrivacyAndSecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy & Security',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18.sp),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Data Collection',
                    'We collect and process the following information:',
                    [
                      'Profile information (name, email, professional details)',
                      'Resume data and preferences',
                      'Usage statistics and interaction data',
                      'Device information and app analytics',
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    'How We Use Your Data',
                    'Your data is used to:',
                    [
                      'Improve resume matching algorithms',
                      'Enhance user experience',
                      'Provide personalized recommendations',
                      'Maintain app security and prevent fraud',
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    'Data Security',
                    'We implement the following security measures:',
                    [
                      'End-to-end encryption for sensitive data',
                      'Regular security audits and updates',
                      'Secure cloud storage with redundancy',
                      'Industry-standard authentication protocols',
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildSection(
                    'Your Rights',
                    'You have the right to:',
                    [
                      'Access your personal data',
                      'Request data modification or deletion',
                      'Opt-out of data collection',
                      'Export your data in a portable format',
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildPrivacyControls(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.deepPurpleAccent,
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Icon(
            Icons.security,
            size: 50.r,
            color: Colors.white,
          ),
          SizedBox(height: 15.h),
          Text(
            'Your Privacy Matters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'We are committed to protecting your data',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        ...items.map((item) => _buildListItem(item)),
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20.r,
            color: Colors.deepPurpleAccent,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyControls(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Controls',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 16.h),
            _buildPrivacyControl(
              'Data Collection',
              'Allow data collection for improved matching',
              true,
            ),
            Divider(),
            _buildPrivacyControl(
              'Analytics',
              'Share anonymous usage data',
              true,
            ),
            Divider(),
            _buildPrivacyControl(
              'Marketing',
              'Receive personalized recommendations',
              false,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Your data export request has been initiated.'),
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Export My Data',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyControl(String title, String subtitle, bool defaultValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SwitchListTile(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
            ),
          ),
          value: defaultValue,
          activeColor: Colors.deepPurpleAccent,
          onChanged: (bool value) {
            setState(() {
              // Update the privacy setting
            });
          },
        );
      },
    );
  }
}
