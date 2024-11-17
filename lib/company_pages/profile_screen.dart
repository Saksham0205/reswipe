import 'package:flutter/material.dart';
import '../models/company_model/job.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Stream<List<Job>>? _companyJobsStream;
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Full-time',
    'Part-time',
    'Internship',
    'Contract'
  ];

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
    } else {
      print('No company ID found for the current user');
    }
  }

  Future<void> _deleteJob(Job job) async {
    try {
      await _authService.deleteJob(job.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildHeader(context),
        actions: [
          Expanded(
              child: Container(
                  height: 50,
                  child: _buildFilterChips()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildJobList(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Posting History',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage and track your job postings',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _filters.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        String filter = _filters[index];
        return FilterChip(
          label: Text(filter),
          selected: _selectedFilter == filter,
          onSelected: (selected) {
            setState(() {
              _selectedFilter = filter;
            });
          },
        );
      },
    );
  }

  Widget _buildJobList() {
    return StreamBuilder<List<Job>>(
      stream: _companyJobsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No jobs posted yet.'),
              ],
            ),
          );
        }

        List<Job> jobs = snapshot.data!;
        if (_selectedFilter != 'All') {
          jobs = jobs
              .where((job) => job.employmentType == _selectedFilter)
              .toList();
        }

        return ListView.separated(
          itemCount: jobs.length,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            Job job = jobs[index];
            return _buildJobCard(job);
          },
        );
      },
    );
  }

  Widget _buildJobCard(Job job) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showJobDetails(context, job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.companyName,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(job.employmentType),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(job.location),
                  const SizedBox(width: 16),
                  const Icon(Icons.currency_rupee, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(job.salaryRange),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String employmentType) {
    Color chipColor;
    switch (employmentType.toLowerCase()) {
      case 'full-time':
        chipColor = Colors.green;
        break;
      case 'part-time':
        chipColor = Colors.orange;
        break;
      case 'contract':
        chipColor = Colors.blue;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        employmentType,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showJobDetails(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _confirmDeleteJob(context, job);
                      },
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Company', job.companyName),
                      _buildDetailSection('Location', job.location),
                      _buildDetailSection(
                          'Employment Type', job.employmentType),
                      _buildDetailSection('Salary Range', job.salaryRange),
                      _buildDetailSection('Description', job.description),
                      _buildListSection(
                          'Responsibilities', job.responsibilities),
                      _buildListSection('Qualifications', job.qualifications),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          ...items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  void _confirmDeleteJob(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text(
              "Are you sure you want to delete this job posting? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CANCEL"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteJob(job);
              },
              child: const Text("DELETE"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
}
