import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../State_management/company_state.dart';
import '../../models/company_model/job.dart';
import 'widgets/header_section.dart';
import 'widgets/filter_section.dart';
import 'widgets/job_list_section.dart';
import 'widgets/job_details_dialog.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _filters = ['All', 'Full-time', 'Part-time', 'Internship', 'Contract'];

  void _showJobDetails(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (context) => JobDetailsDialog(
        job: job,
        onDelete: () => _confirmDeleteJob(context, job),
      ),
    );
  }
  void _confirmDeleteJob(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Deletion",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this job posting?",
            style: TextStyle(fontSize: 14.sp),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "CANCEL",
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<JobBloc>().add(DeleteJob(job.id));
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(
                "DELETE",
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Dispatch LoadJobs event when the screen initializes
    context.read<JobBloc>().add(LoadJobs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<JobBloc, JobState>(
          listener: (context, state) {
            if (state is JobError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is JobInitial) {
              // Add LoadJobs event if we're still in initial state
              context.read<JobBloc>().add(LoadJobs());
              return const Center(child: CircularProgressIndicator());
            }
            if (state is JobLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is JobsLoaded) {
              return Column(
                children: [
                  HeaderSection(
                    currentSortOrder: state.sortOrder,
                    onSortChanged: (order) =>
                        context.read<JobBloc>().add(SortJobs(order)),
                  ),
                  FilterSection(
                    filters: _filters,
                    selectedFilter: state.jobFilter,
                    onFilterSelected: (filter) =>
                        context.read<JobBloc>().add(FilterJobs(filter)),
                  ),
                  Expanded(
                    child: JobListSection(
                      jobsStream: Stream.value(state.jobs),
                      selectedFilter: state.jobFilter,
                      onJobTap: (context, job) => _showJobDetails(context, job),
                      onJobUpdate: (job, updates) =>
                          context.read<JobBloc>().add(UpdateJob(job, updates)),
                      sortOrder: state.sortOrder,
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: Text('Something went wrong. Please try again.'),
            );
          },
        ),
      ),
    );
  }
}
