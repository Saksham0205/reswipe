import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/company_model/job.dart';
import 'job_edit_dialogue.dart';
import 'status_chip.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final Function(Job, Map<String, dynamic>)? onUpdate;
  final bool isEditable;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onUpdate,
    this.isEditable = false,
  });

  void _showEditDialog(BuildContext context) {
    if (onUpdate != null) {
      showDialog(
        context: context,
        builder: (context) => JobEditDialog(
          job: job,
          onUpdate: onUpdate!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title and Edit Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          job.companyName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEditable)
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 20.sp,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () => _showEditDialog(context),
                    ),
                ],
              ),

              SizedBox(height: 12.h),

              // Location and Salary
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      job.location,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                    ),
                  ),
                  Icon(Icons.currency_rupee, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    "${job.salaryRange} (per annum)",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Job Description
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              SizedBox(height: 12.h),

              // Employment Type Status
              Align(
                alignment: Alignment.centerRight,
                child: StatusChip(employmentType: job.employmentType),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
