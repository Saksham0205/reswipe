import 'package:flutter/material.dart';
import '../models/company_model/job.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Stream<List<Job>>? _companyJobsStream;

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
        SnackBar(content: Text('Job deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting job: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Profile'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: Text(
              'Job Posting History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
          ),
          Expanded(
            child: _buildJobList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: Text('Sign Out'),
              onPressed: () => _authService.signOut(),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    return StreamBuilder<List<Job>>(
      stream: _companyJobsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No jobs posted yet.'));
        }

        List<Job> jobs = snapshot.data!;
        return ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            Job job = jobs[index];
            return GestureDetector(
              onTap: () {
                _showJobDetails(context, job);
              },
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(job.location),
                          SizedBox(width: 16),
                          Icon(Icons.work, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(job.employmentType),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showJobDetails(BuildContext context, Job job) {
    showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _confirmDeleteJob(context, job);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Location: ${job.location}'),
                    Text('Type: ${job.employmentType}'),
                    Text('Salary: ${job.salaryRange}'),
                    SizedBox(height: 16),
                    Text(
                      'Description:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(job.description),
                    // SizedBox(height: 8),
                    // Text(
                    //   'Posted on: ${DateFormat('MMM d, yyyy').format(job.createdAt)}',
                    //   style: TextStyle(color: Colors.grey),
                    // ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }

  void _confirmDeleteJob(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this job?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteJob(job);
              },
              child: Text("DELETE"),
            ),
          ],
        );
      },
    );
  }
}