import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/company_model/job.dart';

class JobFilterList extends StatelessWidget {
  final List<Job> jobs;
  final int currentIndex;
  final Function(int) onPageChanged;

  const JobFilterList({
    Key? key,
    required this.jobs,
    required this.currentIndex,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 70.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: jobs.length,
            itemBuilder: (context, index) => _JobFilterCard(
              job: jobs[index],
              isSelected: currentIndex == index,
              onTap: () => onPageChanged(index),
            ),
          ),
        ),
      ],
    );
  }
}

class _JobFilterCard extends StatelessWidget {
  final Job job;
  final bool isSelected;
  final VoidCallback onTap;

  const _JobFilterCard({
    required this.job,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.deepPurple,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              job.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              job.companyName,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
