import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/company_model/applications.dart';
import '../../models/company_model/job.dart';

class JobListingsPage extends StatefulWidget {
  @override
  _JobListingsPageState createState() => _JobListingsPageState();
}

class _JobListingsPageState extends State<JobListingsPage>
    with SingleTickerProviderStateMixin {
  Map<String, String> companyNames = {};
  Map<String, String> companyLogos = {};
  List<Job> jobs = [];
  List<Job> filteredJobs = [];
  late CardSwiperController controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String selectedFilter = 'All';
  final List<String> filters = [
    'All',
    'Remote',
    'Full-time',
    'Part-time',
    'Internship'
  ];
  bool _isLoading = true;
  bool _showEndState = false;

  @override
  void initState() {
    super.initState();
    controller = CardSwiperController();
    _showEndState = false;
    _fetchJobs().then((_) {
      if (mounted) {
        _filterJobs('All');
      }
    });

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


  void _filterJobs(String filter) {
    setState(() {
      selectedFilter = filter;
      _showEndState = false; // Reset end state when changing filters
      if (filter == 'All') {
        filteredJobs = List.from(jobs);
      } else {
        filteredJobs = jobs
            .where((job) =>
        job.employmentType.toLowerCase() == filter.toLowerCase())
            .toList();
      }

      // Reset the controller when filter changes
      if (filteredJobs.isNotEmpty) {
        controller = CardSwiperController();
      }
    });
  }

  Future<void> _fetchJobs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _showEndState = false;
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

  Widget _buildEndState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets3.lottiefiles.com/packages/lf20_success.json', // You can change this to any completion animation
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            repeat: false,
            frameRate: FrameRate(60),
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.deepPurple.shade200,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'You\'re All Caught Up!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'You\'ve viewed all available jobs.\nCheck back later for new opportunities!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedFilter != 'All') ...[
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showEndState = false;
                      _filterJobs('All');
                    });
                  },
                  icon: const Icon(Icons.filter_list, color: Colors.deepPurple),
                  label: const Text('Show All Jobs',
                      style: TextStyle(color: Colors.deepPurple)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showEndState = false;
                  });
                  _fetchJobs();
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Refresh',
                    style: TextStyle(color: Colors.white)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Reswipe',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
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
                _filterJobs(filter);
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.deepPurple,
              checkmarkColor: Colors.white,
              elevation: 3,
              shadowColor: Colors.deepPurple.withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (jobs.isEmpty) {
      return _buildEmptyState(
        message: 'No Jobs Available',
        subMessage: 'Looks like all the good jobs are taking a coffee break! ☕\nCheck back later for fresh opportunities.',
        lottieUrl: 'https://assets1.lottiefiles.com/packages/lf20_EMTsq1.json',
      );
    }

    if (filteredJobs.isEmpty) {
      return _buildEmptyState(
        message: 'No ${selectedFilter} Jobs Found',
        subMessage: 'We couldn\'t find any jobs matching your filter.\nTry selecting a different category!',
        lottieUrl: 'https://assets10.lottiefiles.com/packages/lf20_swnrn2gh.json',
      );
    }

    if (_showEndState) {
      return _buildEndState();
    }

    // If we have exactly one job left, show it in the card swiper
    // The CardSwiper will handle it properly now
    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: controller,
            cardsCount: filteredJobs.length,
            onSwipe: _onSwipe,
            numberOfCardsDisplayed: 1, // Explicitly set to 1
            backCardOffset: const Offset(0, 0), // Prevent showing partial cards
            padding: const EdgeInsets.all(24.0),
            cardBuilder: (context, index, _, __) => JobCard(
              job: filteredJobs[index],
              companyName: companyNames[filteredJobs[index].companyId] ?? 'Unknown Company',
              companyLogo: companyLogos[filteredJobs[index].companyId] ?? '',
            ),
          ),
        ),
        if (filteredJobs.length >= 1) _buildSwipeActions(),
      ],
    );
  }

  Widget _buildEmptyState({
    required String message,
    required String subMessage,
    required String lottieUrl,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            lottieUrl,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            frameRate: FrameRate(60),
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.deepPurple.shade200,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _filterJobs('All');
                },
                icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                label: const Text('Show All Jobs',
                    style: TextStyle(color: Colors.deepPurple)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _fetchJobs();
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Refresh',
                    style: TextStyle(color: Colors.white)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      _applyForJob(context, filteredJobs[previousIndex]);
    }

    // Check if this was the last card
    if (currentIndex == null || currentIndex >= filteredJobs.length - 1) {
      // Delay showing end state to allow the swipe animation to complete
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showEndState = true;
          });
        }
      });
    }
    return true; // Always return true to allow the swipe
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

  JobCard({
    required this.job,
    required this.companyName,
    required this.companyLogo,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationInfo(),
                    const SizedBox(height: 20),
                    _buildDescription(),
                    if (job.responsibilities.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSection('Key Responsibilities', job.responsibilities),
                    ],
                    if (job.qualifications.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSection('Required Qualifications', job.qualifications),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildCompanyLogo(),
                const SizedBox(width: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                job.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job.companyName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: companyLogo.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: companyLogo,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) =>
          const Icon(Icons.business, color: Colors.deepPurple),
          fit: BoxFit.cover,
        )
            : const Icon(Icons.business, color: Colors.deepPurple, size: 30),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.location_on, job.location ?? 'Location not specified'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.work, job.employmentType ?? 'Employment type not specified'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.monetization_on, job.salaryRange ?? 'Salary not specified'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 15,
              height: 1.5,
            ),
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
        const SizedBox(height: 12),
        Text(
          job.description,
          style: TextStyle(
            color: Colors.grey[800],
            height: 1.6,
            fontSize: 15,
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
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
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
                      items[index],
                      style: TextStyle(
                        color: Colors.grey[800],
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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
