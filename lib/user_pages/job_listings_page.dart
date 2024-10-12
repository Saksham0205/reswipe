import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String companyId;

  Job({
    this.id = '',
    required this.title,
    required this.description,
    this.companyId = '',
  });

  factory Job.fromMap(Map<String, dynamic> data, String id) {
    return Job(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      companyId: data['companyId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'companyId': companyId,
    };
  }
}

class JobListingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Job> jobs = snapshot.data!.docs.map((doc) => Job.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

        return PageView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            Job job = jobs[index];
            return JobCard(
              title: job.title,
              company: job.companyId,
              description: job.description,
              onApply: () => _applyForJob(context, job.id, job.title),
            );
          },
        );
      },
    );
  }

  void _applyForJob(BuildContext context, String jobId, String jobTitle) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      String? resumeUrl = userData['resumeUrl'];
      if (resumeUrl == null || resumeUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload your resume before applying')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('applications').add({
        'jobId': jobId,
        'jobTitle': jobTitle,
        'userId': userId,
        'applicantName': userData['name'] ?? 'Unknown',
        'qualification': userData['qualification'] ?? '',
        'jobProfile': userData['jobProfile'] ?? '',
        'resumeUrl': resumeUrl,
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