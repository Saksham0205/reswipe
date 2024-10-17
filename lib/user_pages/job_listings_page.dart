import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../models/company_model/applications.dart';
import '../models/company_model/job.dart';

class JobListingsPage extends StatefulWidget {
  @override
  _JobListingsPageState createState() => _JobListingsPageState();
}

class _JobListingsPageState extends State<JobListingsPage> with SingleTickerProviderStateMixin {
  Map<String, String> companyNames = {};
  List<Job> jobs = [];
  late CardSwiperController controller;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    controller = CardSwiperController();
    _fetchJobs();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('jobs').get();
      List<Job> fetchedJobs = querySnapshot.docs.map((doc) => Job.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

      // Fetch company names
      Set<String> companyIds = fetchedJobs.map((job) => job.companyId).toSet();
      for (String companyId in companyIds) {
        DocumentSnapshot companyDoc = await FirebaseFirestore.instance.collection('users').doc(companyId).get();
        if (companyDoc.exists) {
          companyNames[companyId] = companyDoc.get('companyName') ?? 'Unknown Company';
        } else {
          companyNames[companyId] = 'Unknown Company';
        }
      }

      setState(() {
        jobs = fetchedJobs;
      });
    } catch (e) {
      print('Error fetching jobs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load jobs. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Listings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.deepPurple.shade200],
          ),
        ),
        child: jobs.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
          children: [
            Expanded(child: _buildCardSwiper()),
            _buildSwipeActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSwiper() {
    return FadeTransition(
      opacity: _animation,
      child: CardSwiper(
        controller: controller,
        cardsCount: jobs.length,
        onSwipe: _onSwipe,
        padding: const EdgeInsets.all(24.0),
        cardBuilder: (context, index, _, __) => JobCard(
          job: jobs[index],
          companyName: companyNames[jobs[index].companyId] ?? 'Unknown Company',
          onApply: () => _applyForJob(context, jobs[index].id, jobs[index].title),
        ),
      ),
    );
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      _applyForJob(context, jobs[previousIndex].id, jobs[previousIndex].title);
    }
    if (currentIndex == null) {
      _fetchJobs();
      return false;
    }
    return true;
  }

  Widget _buildSwipeActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            onPressed: () {
              controller.swipe(CardSwiperDirection.left);
            },
            icon: Icons.close,
            color: Colors.red,
          ),
          _buildActionButton(
            onPressed: () {
              controller.swipe(CardSwiperDirection.right);
            },
            icon: Icons.check,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 32, color: color),
        onPressed: onPressed,
      ),
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
          const SnackBar(
            content: Text('Please upload your resume before applying'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Application application = Application(
        id: '',
        jobId: jobId,
        jobTitle: jobTitle,
        userId: userId,
        applicantName: userData['name'] ?? 'Unknown',
        qualification: userData['qualification'] ?? '',
        jobProfile: userData['jobProfile'] ?? '',
        resumeUrl: resumeUrl,
        status: 'pending',
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('applications')
          .add(application.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class JobCard extends StatelessWidget {
  final Job job;
  final String companyName;
  final VoidCallback onApply;

  JobCard({
    required this.job,
    required this.companyName,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.deepPurple.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                job.companyName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.location_on, job.location ?? 'Location not specified'),
              _buildInfoRow(Icons.work, job.employmentType ?? 'Employment type not specified'),
              _buildInfoRow(Icons.monetization_on, job.salaryRange ?? 'Salary not specified'),
              const SizedBox(height: 16),
              Text(
                'Job Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    job.description,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildApplyButton(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Center(
      child: ElevatedButton(
        child: const Text('Apply Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: onApply,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

}