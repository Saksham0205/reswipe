import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class JobSeekerHomeScreen extends StatefulWidget {
  @override
  _JobSeekerHomeScreenState createState() => _JobSeekerHomeScreenState();
}

class _JobSeekerHomeScreenState extends State<JobSeekerHomeScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  String _qualification = '';
  String _jobProfile = '';
  String _resumeUrl = '';
  File? _resumeFile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _qualification = userData['qualification'] ?? '';
        _jobProfile = userData['jobProfile'] ?? '';
        _resumeUrl = userData['resumeUrl'] ?? '';
      });
    }
  }

  Future<void> _pickAndUploadResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _resumeFile = File(result.files.single.path!);
        });

        // Upload to Firebase Storage
        String userId = FirebaseAuth.instance.currentUser!.uid;
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('resumes')
            .child('$userId.pdf');

        await storageRef.putFile(_resumeFile!);
        String downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with the URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'resumeUrl': downloadUrl,
        });

        setState(() {
          _resumeUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload resume: $e')),
      );
    }
  }

  void _updateProfile() async {
    if (_profileFormKey.currentState!.validate()) {
      _profileFormKey.currentState!.save();
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'qualification': _qualification,
          'jobProfile': _jobProfile,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Job Seeker Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.work), text: 'Job Listings'),
              Tab(icon: Icon(Icons.history), text: 'Applications'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildProfileTab(),
            _buildJobListingsTab(),
            _buildApplicationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Form(
        key: _profileFormKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _qualification,
                decoration: const InputDecoration(labelText: 'Qualification'),
                validator: (value) => value!.isEmpty ? 'Enter your qualification' : null,
                onSaved: (value) => _qualification = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _jobProfile,
                decoration: const InputDecoration(labelText: 'Job Profile'),
                validator: (value) => value!.isEmpty ? 'Enter your job profile' : null,
                onSaved: (value) => _jobProfile = value!,
              ),
              const SizedBox(height: 20),
              Text('Resume', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _resumeUrl.isNotEmpty
                  ? const Text('Resume uploaded successfully')
                  : const Text('No resume uploaded'),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Resume (PDF)'),
                onPressed: _pickAndUploadResume,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Update Profile'),
                onPressed: _updateProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobListingsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> jobs = snapshot.data!.docs;

        return PageView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data = jobs[index].data() as Map<String, dynamic>;
            return JobCard(
              title: data['title'],
              company: data['companyId'],
              description: data['description'],
              onApply: () => _applyForJob(jobs[index].id, data['title']),
            );
          },
        );
      },
    );
  }

  Widget _buildApplicationsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No applications yet'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot application = snapshot.data!.docs[index];
            Map<String, dynamic> data = application.data() as Map<String, dynamic>;

            Color statusColor;
            IconData statusIcon;
            switch (data['status']) {
              case 'accepted':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                break;
              case 'rejected':
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                break;
              default:
                statusColor = Colors.orange;
                statusIcon = Icons.hourglass_empty;
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(data['jobTitle'] ?? 'Unknown Job'),
                subtitle: Text('Status: ${data['status'] ?? 'pending'}'),
                trailing: Icon(statusIcon, color: statusColor),
              ),
            );
          },
        );
      },
    );
  }

  void _applyForJob(String jobId, String jobTitle) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (_resumeUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your resume before applying')),
      );
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('applications').add({
        'jobId': jobId,
        'jobTitle': jobTitle,
        'userId': userId,
        'applicantName': userData['name'] ?? 'Unknown',
        'qualification': userData['qualification'] ?? '',
        'jobProfile': userData['jobProfile'] ?? '',
        'resumeUrl': _resumeUrl,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply: $e')),
      );
    }
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String description;
  final VoidCallback onApply;

  JobCard({
    required this.title,
    required this.company,
    required this.description,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            Text(company, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text(description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text('Skip'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
                ElevatedButton(
                  child: const Text('Apply'),
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}