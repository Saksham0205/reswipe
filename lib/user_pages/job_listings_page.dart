import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../models/company_model/job.dart';

class JobListingsPage extends StatefulWidget {
  @override
  _JobListingsPageState createState() => _JobListingsPageState();
}

class _JobListingsPageState extends State<JobListingsPage> with SingleTickerProviderStateMixin {
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
      setState(() {
        jobs = querySnapshot.docs.map((doc) => Job.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      });
    } catch (e) {
      print('Error fetching jobs: $e');
      // Handle error (show a snackbar, for example)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Listings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: jobs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(child: _buildCardSwiper()),
          _buildSwipeActions(),
        ],
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
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
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
  final Job job;
  final VoidCallback onApply;

  JobCard({
    required this.job,
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
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
              Text(job.companyId, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(job.description),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  child: const Text('Apply Now',style: TextStyle(color: Colors.white),),
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}