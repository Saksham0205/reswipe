import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reswipe/company_pages/profile/widgets/sort_button.dart';

import '../utils/job_sorter.dart';

class HeaderSection extends StatelessWidget {
  final SortOrder currentSortOrder;
  final ValueChanged<SortOrder> onSortChanged;

  const HeaderSection({
    Key? key,
    required this.currentSortOrder,
    required this.onSortChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Posting History',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Manage and track your job postings',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.w),
          SortButton(
            currentOrder: currentSortOrder,
            onSortChanged: onSortChanged,
          ),

        ],
      ),
    );
  }
}