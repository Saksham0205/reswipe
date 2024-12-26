import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/company_model/job.dart';
import '../utils/job_sorter.dart';
import 'job_card.dart';

class JobListSection extends StatelessWidget {
  final Stream<List<Job>>? jobsStream;
  final String selectedFilter;
  final Function(BuildContext, Job) onJobTap;
  final SortOrder sortOrder;

  const JobListSection({
    Key? key,
    required this.jobsStream,
    required this.selectedFilter,
    required this.onJobTap,
    required this.sortOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Job>>(
      stream: jobsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off, size: 48.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  'No jobs posted yet.',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          );
        }

        List<Job> jobs = snapshot.data!;
        if (selectedFilter != 'All') {
          jobs = jobs.where((job) => job.employmentType == selectedFilter).toList();
        }

        // Apply sorting
        jobs = JobSorter.sortByDate(jobs, sortOrder);

        return ListView.separated(
          itemCount: jobs.length,
          padding: EdgeInsets.all(16.w),
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) => JobCard(
            job: jobs[index],
            onTap: () => onJobTap(context, jobs[index]),
          ),
        );
      },
    );
  }
}