import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/company_model/applications.dart';
import 'favourite_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Application> applications = [];
  List<Application> favoriteApplications = [];
  late CardSwiperController controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = CardSwiperController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
    _loadFavorites();
    _fetchApplications();
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  //Functions

  Future<void> _fetchApplications() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('applications')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      setState(() {
        applications = querySnapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList();
        isLoading = false;

        // Reset the controller when we get new applications
        if (applications.isNotEmpty) {
          controller = CardSwiperController();
        }
      });
    } catch (e) {
      print('Error fetching applications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoriteIds = prefs.getStringList('favoriteApplicationIds');
    if (favoriteIds != null && favoriteIds.isNotEmpty) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('applications')
            .where(FieldPath.documentId, whereIn: favoriteIds)
            .get();
        setState(() {
          favoriteApplications = querySnapshot.docs
              .map((doc) => Application.fromFirestore(doc))
              .toList();
        });
      } catch (e) {
        print('Error loading favorite applications: $e');
      }
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds = favoriteApplications.map((a) => a.id).toList();
    await prefs.setStringList('favoriteApplicationIds', favoriteIds);
  }

  Future<void> _incrementCompanyLikesCount(Application applicant) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicant.id)
          .update({
        'companyLikesCount': FieldValue.increment(1)
      });
      print('Incremented companyLikesCount for ${applicant.applicantName}');
    } catch (e) {
      print('Error incrementing companyLikesCount: $e');
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
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children:[
              _buildAppBar(),
              Expanded(
                child: _buildMainContent(),
              ),
              if (applications.isNotEmpty) _buildSwipeActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.work_outline, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Reswipe',
                style: GoogleFonts.pacifico(
                  fontSize: 28,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 28),
                color: Colors.deepPurple,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _buildFavoriteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSwiper() {
    if (applications.isEmpty) {
      return _buildNoApplicationsView();
    }

    return FadeTransition(
      opacity: _animation,
      child: CardSwiper(
        controller: controller,
        cardsCount: applications.length,
        numberOfCardsDisplayed: 1,
        onSwipe: _onSwipe,
        onEnd: _onEnd,
        padding: EdgeInsets.zero,
        cardBuilder: (context, index, horizontalThreshold, verticalThreshold) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _buildCard(applications[index]),
          );
        },
      ),
    );
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (previousIndex >= 0 && previousIndex < applications.length) {
      Application currentApplication = applications[previousIndex];
      if (direction == CardSwiperDirection.right) {
        _updateApplicationStatus(currentApplication.id, 'Accepted');
        _incrementCompanyLikesCount(applications[previousIndex]);
        setState(() {
          favoriteApplications.add(applications[previousIndex]);
          _saveFavorites();
        });
      }
      else if (direction == CardSwiperDirection.left) {
        // Handle left swipe (Reject)
        _updateApplicationStatus(currentApplication.id, 'Rejected');
      }
    }

    // If this was the last card
    if (currentIndex == null || currentIndex >= applications.length) {
      _onEnd();
      return false;
    }
    return true;
  }

  Future<void> _updateApplicationStatus(String applicationId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({
        'status': status,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('Updated application $applicationId status to $status');
    } catch (e) {
      print('Error updating application status: $e');
    }
  }

  void _onEnd() {
    setState(() {
      applications.clear();
      // Create a new controller for the next batch
      controller = CardSwiperController();
    });

    // Fetch new applications
    _fetchApplications();
  }



  Widget _buildCard(Application application) {
    final PageController pageController = PageController();

    return Card(
      margin: const EdgeInsets.all(16), // Add padding around the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Add rounded corners
      ),
      child: ClipRRect( // Clip the contents to match card's border radius
        borderRadius: BorderRadius.circular(20),
        child: PageView(
          controller: pageController,
          children: [
            _buildFirstPage(application),
            _buildSecondPage(application),
            _buildThirdPage(application),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstPage(Application application) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.applicantName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    application.qualification,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    application.college ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: application.skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.deepPurple.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                skill,
                                style: TextStyle(
                                  color: Colors.deepPurple.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: ElevatedButton.icon(
                            onPressed: () => _viewResume(application),
                            icon: const Icon(Icons.description, color: Colors.white, size: 18),
                            label: const Text(
                              'Resume',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showApplicationDetails(application),
                          icon: const Icon(Icons.info_outline),
                          color: Colors.deepPurple,
                          tooltip: 'View Details',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSecondPage(Application application) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: application.experience.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(application.experience[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPage(Application application) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: application.achievements.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(application.achievements[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FavoritesScreen(
              favoriteApplications: favoriteApplications,
              clearAllFavorites: _clearAllFavorites,
              removeFromFavorites: _removeFromFavorites,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.favorite, color: Colors.deepPurple, size: 28),
            if (favoriteApplications.isNotEmpty)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${favoriteApplications.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _viewResume(Application application) {
    // Implement resume viewing logic
    // You might want to use a package like url_launcher to open the PDF
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return _buildLoadingShimmer();
    }

    if (applications.isEmpty) {
      return _buildNoApplicationsView();
    }

    return _buildCardSwiper();
  }

  Widget _buildNoApplicationsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets1.lottiefiles.com/packages/lf20_EMTsq1.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          Text(
            'No More Resumes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Check back later for new applications',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchApplications,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }


  void _showApplicationDetails(Application application) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDetailItem('Name', application.applicantName),
                      _buildDetailItem('Job Title', application.jobTitle),
                      _buildDetailItem('Job Profile', application.jobProfile),
                      _buildDetailItem('Qualification', application.qualification),
                      _buildDetailItem('Status', application.status),
                      if (application.timestamp != null)
                        _buildDetailItem(
                          'Applied on',
                          application.timestamp!.toString().split(' ')[0],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            onPressed: () {
              controller.swipe(CardSwiperDirection.left);
            },
            icon: Icons.close,
            color: Colors.red,
            label: 'Skip',
          ),
          const SizedBox(width: 48), // Add space between buttons
          _buildActionButton(
            onPressed: () {
              controller.swipe(CardSwiperDirection.right);
            },
            icon: Icons.favorite,
            color: Colors.green,
            label: 'Like',
            isLarge: true,
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
    bool isLarge = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: onPressed,
              child: Padding(
                padding: EdgeInsets.all(isLarge ? 20 : 16),
                child: Icon(
                  icon,
                  size: isLarge ? 40 : 32,
                  color: color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _clearAllFavorites() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Favorites'),
          content: const Text('Are you sure you want to remove all favorites? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  favoriteApplications.clear();
                  _saveFavorites();
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _removeFromFavorites(Application application) {
    setState(() {
      favoriteApplications.removeWhere((app) => app.id == application.id);
      _saveFavorites();
    });
  }

}