import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

import '../models/company_model/applications.dart';
import '../models/company_model/job.dart';

class JobListingsPage extends StatefulWidget {
  @override
  _JobListingsPageState createState() => _JobListingsPageState();
}

class _JobListingsPageState extends State<JobListingsPage>
    with SingleTickerProviderStateMixin {
  Map<String, String> companyNames = {};
  Map<String, String> companyLogos = {};
  List<Job> jobs = [];
  List<String> savedJobs = [];
  late CardSwiperController controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isFiltering = false;
  String selectedFilter = 'All';
  final List<String> filters = [
    'All',
    'Remote',
    'Full-time',
    'Part-time',
    'Internship'
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = CardSwiperController();
    _fetchJobs();
    _loadSavedJobs();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    controller.dispose();  // Dispose the card swiper controller
    _animationController.dispose();  // Dispose the animation controller
    super.dispose();
  }

  Future<void> _loadSavedJobs() async {
    if (!mounted) return;

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('savedJobs')
          .get();

      if (!mounted) return;

      setState(() {
        savedJobs = doc.docs.map((d) => d.id).toList();
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error loading saved jobs: $e');
    }
  }


  Future<void> _fetchJobs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('jobs').get();
      List<Job> fetchedJobs = querySnapshot.docs
          .map((doc) => Job.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Fetch company details
      Set<String> companyIds = fetchedJobs.map((job) => job.companyId).toSet();
      for (String companyId in companyIds) {
        if (!mounted) return;

        DocumentSnapshot companyDoc = await FirebaseFirestore.instance
            .collection('applications')
            .doc(companyId)
            .get();
        if (companyDoc.exists) {
          companyNames[companyId] =
              companyDoc.get('companyName') ?? 'Unknown Company';
          companyLogos[companyId] = companyDoc.get('logoUrl') ?? '';
        }
      }

      if (!mounted) return;

      setState(() {
        jobs = fetchedJobs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      print('Error fetching jobs: $e');
      setState(() {
        _isLoading = false;
        jobs = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load jobs. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilters(),
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (jobs.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(child: _buildCardSwiper()),
        _buildSwipeActions(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets1.lottiefiles.com/packages/lf20_EMTsq1.json', // Empty box animation
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            'No Jobs Available',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Looks like all the good jobs are taking a coffee break! ☕\nCheck back later for fresh opportunities.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _fetchJobs();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Refresh', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Reswipe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () {
                  // Navigate to saved jobs
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {
                  // Navigate to profile
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                  // Implement filtering logic
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.deepPurple,
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 400,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  bool _onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      _applyForJob(context, jobs[previousIndex]);
    }
    if (currentIndex == null) {
      _fetchJobs();
      return false;
    }
    return true;
  }

  Widget _buildCardSwiper() {
    return CardSwiper(
      controller: controller,
      cardsCount: jobs.length,
      onSwipe: _onSwipe,
      padding: const EdgeInsets.all(24.0),
      cardBuilder: (context, index, _, __) => JobCard(
        job: jobs[index], //
        companyName: companyNames[jobs[index].companyId] ?? 'Unknown Company',
        companyLogo: companyLogos[jobs[index].companyId] ?? '',
        isSaved: savedJobs.contains(jobs[index].id),
        onApply: () => _applyForJob(context, jobs[index]),
        onSave: () => _toggleSaveJob(jobs[index].id),
        onShare: () => _shareJob(jobs[index]),
      ),
    );
  }

  Future<void> _toggleSaveJob(String jobId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final savedJobRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedJobs')
        .doc(jobId);

    if (savedJobs.contains(jobId)) {
      await savedJobRef.delete();
      setState(() {
        savedJobs.remove(jobId);
      });
    } else {
      await savedJobRef.set({'savedAt': DateTime.now()});
      setState(() {
        savedJobs.add(jobId);
      });
    }
  }

  Future<void> _shareJob(Job job) async {
    final String shareText = '''
${job.title} at ${job.companyName}
${job.location} • ${job.employmentType}
Salary: ${job.salaryRange}

Apply now on our platform!
''';
    await Share.share(shareText);
  }

  Widget _buildSwipeActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            onPressed: () => controller.swipe(CardSwiperDirection.left),
            icon: Icons.close,
            color: Colors.red,
            label: 'Skip',
          ),
          _buildActionButton(
            onPressed: () => controller.swipe(CardSwiperDirection.right),
            icon: Icons.check,
            color: Colors.green,
            label: 'Apply',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, size: 32, color: color),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _applyForJob(BuildContext context, Job job) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      String? resumeUrl = userData['resumeUrl'];
      if (resumeUrl == null || resumeUrl.isEmpty) {
        _showErrorSnackBar('Please upload your resume before applying');
        return;
      }

      // Helper function to safely convert to List<String>
      List<String> safeListFromDynamic(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          return value.map((e) => e.toString()).toList();
        }
        if (value is String) {
          return [value]; // Convert single string to list
        }
        return [];
      }

      // Safely get user data with proper type conversion
      Application application = Application(
        id: '',
        jobId: job.id,
        jobTitle: job.title,
        jobDescription: job.description,
        jobResponsibilities: job.responsibilities,
        jobQualifications: job.qualifications,
        jobSalaryRange: job.salaryRange,
        jobLocation: job.location,
        jobEmploymentType: job.employmentType,
        companyId: job.companyId,
        companyName: job.companyName,
        userId: userId,
        applicantName: userData['name']?.toString() ?? 'Unknown',
        email: userData['email']?.toString() ?? '',
        qualification: userData['qualification']?.toString() ?? '',
        jobProfile: userData['jobProfile']?.toString() ?? '',
        // Safely convert lists using the helper function
        skills: safeListFromDynamic(userData['skills']),
        experience: safeListFromDynamic(userData['experience']),
        college: userData['college']?.toString() ?? '',
        achievements: safeListFromDynamic(userData['achievements']),
        projects: safeListFromDynamic(userData['projects']),
        resumeUrl: resumeUrl,
        profileImageUrl: userData['profileImageUrl']?.toString() ?? '',
        status: 'pending',
        timestamp: DateTime.now(),
        companyLikesCount: 0,
      );

      await FirebaseFirestore.instance
          .collection('applications')
          .add(application.toMap());

      _showSuccessSnackBar('Application submitted successfully!');
    } catch (e) {
      print('Application error details: $e'); // Add detailed error logging
      _showErrorSnackBar('Failed to apply: $e');
    }
  }
  void _showSuccessSnackBar(String message) {
    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class JobCard extends StatelessWidget {
  final Job job;
  final String companyName;
  final String companyLogo;
  final bool isSaved;
  final VoidCallback onApply;
  final VoidCallback onSave;
  final VoidCallback onShare;

  JobCard({
    required this.job,
    required this.companyName,
    required this.companyLogo,
    required this.isSaved,
    required this.onApply,
    required this.onSave,
    required this.onShare,
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
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompanyInfo(),
                    const SizedBox(height: 16),
                    _buildJobDetails(),
                    const SizedBox(height: 16),
                    _buildDescription(),
                    if (job.responsibilities.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSection(
                          'Key Responsibilities', job.responsibilities),
                    ],
                    if (job.qualifications.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSection(
                          'Required Qualifications', job.qualifications),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                if (companyLogo.isNotEmpty)
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: companyLogo,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.business),
                      ),
                    ),
                  )
                else
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.business, color: Colors.deepPurple),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        job.companyName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                  Icons.location_on, job.location ?? 'Location not specified'),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.work,
                  job.employmentType ?? 'Employment type not specified'),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.monetization_on,
                  job.salaryRange ?? 'Salary not specified'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About the Role',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailCard(
                icon: Icons.timer,
                title: 'Posted',
                value: '2 days ago',
              ),
              _buildDetailCard(
                icon: Icons.people_outline,
                title: 'Applicants',
                value: '45+',
              ),
              _buildDetailCard(
                icon: Icons.access_time,
                title: 'Type',
                value: job.employmentType ?? 'N/A',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          job.description,
          style: TextStyle(
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Apply Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildIconButton(
            icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
            onPressed: onSave,
            tooltip: isSaved ? 'Remove from saved' : 'Save job',
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.share_outlined,
            onPressed: onShare,
            tooltip: 'Share job',
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.deepPurple),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}

// Add these extensions to handle potential null values more elegantly
extension StringExtension on String? {
  String get orEmpty => this ?? '';
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

// Add an animation mixin for more sophisticated animations
mixin CardAnimationMixin<T extends StatefulWidget> on State<T> {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this as TickerProvider,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}
