import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class ApplicationsPage extends StatefulWidget {
  @override
  _ApplicationsPageState createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  Set<String> expandedCards = {};
  final ScrollController _scrollController = ScrollController();

  void toggleCard(String applicationId) {
    setState(() {
      if (expandedCards.contains(applicationId)) {
        expandedCards.remove(applicationId);
      } else {
        expandedCards.add(applicationId);
      }
    });
  }

  Widget _buildStatusChip(String status) {
    final Map<String, ({Color color, IconData icon, String label})> statusConfig = {
      'accepted': (
      color: const Color(0xFF4CAF50),
      icon: Icons.check_circle_outlined,
      label: 'Accepted'
      ),
      'rejected': (
      color: const Color(0xFFE53935),
      icon: Icons.cancel_outlined,
      label: 'Rejected'
      ),
      'pending': (
      color: const Color(0xFFFFA726),
      icon: Icons.hourglass_empty_rounded,
      label: 'Pending'
      ),
    };

    final config = statusConfig[status.toLowerCase()] ??
        statusConfig['pending']!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, color: config.color, size: 16.r),
          SizedBox(width: 6.w),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 6.h),
                width: 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B46C1),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.grey[800],
                    height: 1.5.h,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'My Applications',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red[300]),
                  SizedBox(height: 16.h),
                  Text(
                    'Something went wrong',
                    style: TextStyle(color: Colors.red[300], fontSize: 16.sp),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF6B46C1),
                strokeWidth: 2.w,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.network(
                    'https://assets7.lottiefiles.com/packages/lf20_hl5n0bwb.json',
                    height: 200.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'No Applications Yet',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'Start applying to jobs to track your applications here',
                        style: TextStyle(
                          color: const Color(0xFF718096),
                          fontSize: 16.sp,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot application = snapshot.data!.docs[index];
              Map<String, dynamic> data = application.data() as Map<String, dynamic>;
              bool isExpanded = expandedCards.contains(application.id);

              return Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 300)),
                  SlideEffect(
                    begin: Offset(0, 0.1),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 300),
                  ),
                ],
                child: Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: () => toggleCard(application.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['jobTitle'] ?? 'Unknown Job',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2D3748),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        data['companyName'] ?? 'Unknown Company',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStatusChip(data['status'] ?? 'pending'),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildDetailRow(
                              Icons.calendar_today_rounded,
                              'Applied on: ${DateFormat('MMM d, yyyy').format((data['timestamp'] as Timestamp).toDate())}',
                            ),
                            if (!isExpanded)
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(top: 8.h),
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            if (isExpanded) ...[
                              Divider(height: 32.h, thickness: 1.h),
                              _buildDetailRow(
                                Icons.location_on_outlined,
                                data['jobLocation'] ?? 'Unknown Location',
                              ),
                              _buildDetailRow(
                                Icons.work_outline_rounded,
                                data['jobEmploymentType'] ?? 'Not specified',
                              ),
                              _buildDetailRow(
                                Icons.currency_rupee,
                                data['jobSalaryRange'] ?? 'Not specified',
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                data['jobDescription'] ?? 'No description available',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              if (data['jobResponsibilities'] != null) ...[
                                _buildSection(
                                  'Responsibilities',
                                  List<String>.from(data['jobResponsibilities']),
                                ),
                                SizedBox(height: 24.h),
                              ],
                              if (data['jobQualifications'] != null) ...[
                                _buildSection(
                                  'Qualifications',
                                  List<String>.from(data['jobQualifications']),
                                ),
                              ],
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(top: 16.h),
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}