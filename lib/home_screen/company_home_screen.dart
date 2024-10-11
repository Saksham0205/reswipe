  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:url_launcher/url_launcher.dart';

  class CompanyHomeScreen extends StatefulWidget {
    @override
    _CompanyHomeScreenState createState() => _CompanyHomeScreenState();
  }

  class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
    final _jobFormKey = GlobalKey<FormState>();
    String _jobTitle = '';
    String _jobDescription = '';

    void _postJob() async {
      if (_jobFormKey.currentState!.validate()) {
        _jobFormKey.currentState!.save();
        try {
          await FirebaseFirestore.instance.collection('jobs').add({
            'title': _jobTitle,
            'description': _jobDescription,
            'companyId': FirebaseAuth.instance.currentUser!.uid,
            'timestamp': FieldValue.serverTimestamp(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Job posted successfully!')),
          );
          _jobFormKey.currentState!.reset();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to post job: $e')),
          );
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Company Dashboard'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.work), text: 'Post Job'),
                Tab(icon: Icon(Icons.person_search), text: 'Review Applications'),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              _buildPostJobTab(),
              _buildReviewApplicationsTab(),
            ],
          ),
        ),
      );
    }

    Widget _buildPostJobTab() {
      return Form(
        key: _jobFormKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Job Title'),
                validator: (value) => value!.isEmpty ? 'Enter a job title' : null,
                onSaved: (value) => _jobTitle = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Job Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a job description' : null,
                onSaved: (value) => _jobDescription = value!,
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Post Job'),
                onPressed: _postJob,
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildReviewApplicationsTab() {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('companyId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, jobSnapshot) {
          if (jobSnapshot.hasError) {
            return Center(child: Text('Error loading jobs'));
          }

          if (jobSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<String> companyJobIds =
              jobSnapshot.data!.docs.map((doc) => doc.id).toList();

          if (companyJobIds.isEmpty) {
            return Center(child: Text('No jobs posted yet'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('applications')
                .where('jobId', whereIn: companyJobIds)
                .snapshots(),
            builder: (context, applicationSnapshot) {
              if (applicationSnapshot.hasError) {
                return Center(child: Text('Error loading applications'));
              }

              if (applicationSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (applicationSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No applications yet'));
              }

              return PageView.builder(
                itemCount: applicationSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot application =
                      applicationSnapshot.data!.docs[index];
                  Map<String, dynamic> applicationData =
                      application.data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            applicationData['applicantName'] ??
                                'Unknown Applicant',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Job: ${applicationData['jobTitle'] ?? 'Unknown Job'}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 16),
                          Text(
                              'Qualification: ${applicationData['qualification'] ?? 'Not specified'}'),
                          Text(
                              'Job Profile: ${applicationData['jobProfile'] ?? 'Not specified'}'),
                          SizedBox(height: 16),
                          if (applicationData['resumeUrl'] != null)
                            ElevatedButton.icon(
                              icon: Icon(Icons.description),
                              label: Text('View Resume'),
                              onPressed: () {
                                // Implement PDF viewer or open URL in browser
                              },
                            ),
                          SizedBox(height: 16),
                          if (applicationData['status'] == 'pending')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  child: Text('Accept'),
                                  onPressed: () => _respondToApplication(
                                      application.id, 'accepted'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                ),
                                ElevatedButton(
                                  child: Text('Reject'),
                                  onPressed: () => _respondToApplication(
                                      application.id, 'rejected'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                ),
                              ],
                            )
                          else
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: applicationData['status'] == 'accepted'
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                applicationData['status']?.toUpperCase() ??
                                    'UNKNOWN',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }


    void _respondToApplication(String applicationId, String status) async {
      try {
        await FirebaseFirestore.instance
            .collection('applications')
            .doc(applicationId)
            .update({
          'status': status,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application $status')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update application: $e')),
        );
      }
    }
  }
