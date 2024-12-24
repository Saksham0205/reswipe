import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyAndSecurityScreen extends StatefulWidget {
  const PrivacyAndSecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyAndSecurityScreen> createState() => _PrivacyAndSecurityScreenState();
}

class _PrivacyAndSecurityScreenState extends State<PrivacyAndSecurityScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _itemDelays = [0.0, 0.1, 0.2, 0.3, 0.4];
  bool dataCollection = true;
  bool analytics = true;
  bool marketing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Privacy & Security',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimatedSection(
                      'Data Collection',
                      'We collect and process the following:',
                      ['Profile information', 'Resume data', 'Usage statistics', 'Device information'],
                      0.0,
                    ),
                    _buildAnimatedSection(
                      'Data Usage',
                      'Your data helps us:',
                      ['Improve matching', 'Enhance experience', 'Provide recommendations', 'Maintain security'],
                      0.1,
                    ),
                    _buildAnimatedSection(
                      'Security Measures',
                      'We protect your data with:',
                      ['End-to-end encryption', 'Regular audits', 'Secure storage', 'Standard protocols'],
                      0.2,
                    ),
                    _buildPrivacyControls(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security,
              size: 40.r,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your Privacy Matters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'We are committed to protecting your data',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection(String title, String subtitle, List<String> items, double delay) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 24.h),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.h),
              ...items.map((item) => _buildListItem(item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 16.sp,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyControls() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Controls',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 20.h),
              _buildSwitch(
                'Data Collection',
                'Allow data collection for improved matching',
                dataCollection,
                    (value) => setState(() => dataCollection = value),
              ),
              Divider(height: 32.h),
              _buildSwitch(
                'Analytics',
                'Share anonymous usage data',
                analytics,
                    (value) => setState(() => analytics = value),
              ),
              Divider(height: 32.h),
              _buildSwitch(
                'Marketing',
                'Receive personalized recommendations',
                marketing,
                    (value) => setState(() => marketing = value),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Your data export request has been initiated.', style: TextStyle(fontSize: 14.sp)),
                        backgroundColor: Colors.blue[700],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Export My Data',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
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
          color: Colors.grey[600],
        ),
      ),
      value: value,
      activeColor: Colors.blue[700],
      onChanged: onChanged,
    );
  }
}