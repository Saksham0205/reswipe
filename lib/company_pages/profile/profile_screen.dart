import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/company_model/job.dart';
import '../../services/firestore_service.dart';
import 'utils/job_sorter.dart';
import 'widgets/header_section.dart';
import 'widgets/filter_section.dart';
import 'widgets/job_list_section.dart';
import 'widgets/job_details_dialog.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Stream<List<Job>>? _companyJobsStream;
  String _selectedFilter = 'All';
  SortOrder _sortOrder = SortOrder.newest;
  final List<String> _filters = ['All', 'Full-time', 'Part-time', 'Internship', 'Contract'];

  @override
  void initState() {
    super.initState();
    _loadCompanyJobs();
  }
  void _loadCompanyJobs() async {
    String? companyId = await _authService.getCurrentCompanyId();
    if (companyId != null) {
      setState(() {
        _companyJobsStream = _authService.getJobsByCompany(companyId);
      });
    }
  }

  Future<void> _deleteJob(Job job) async {
    try {
      await _authService.deleteJob(job.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Job deleted successfully',
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error deleting job: $e',
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    }
  }

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
            "Are you sure you want to delete this job posting? This action cannot be undone.",
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteJob(job);
              },
              child: Text(
                "DELETE",
                style: TextStyle(fontSize: 14.sp),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeaderSection(
              currentSortOrder: _sortOrder,
              onSortChanged: (order) => setState(() => _sortOrder = order),
            ),
            FilterSection(
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterSelected: (filter) => setState(() => _selectedFilter = filter),

            ),
            Expanded(
              child: JobListSection(
                jobsStream: _companyJobsStream,
                selectedFilter: _selectedFilter,
                onJobTap: _showJobDetails,
                sortOrder: _sortOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
