import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reswipe/company_pages/home_screen/favourites/favourite_screen.dart';
import 'package:reswipe/company_pages/home_screen/widgets/swipe_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/company_model/applications.dart';
import 'widgets/app_bar.dart';
import 'widgets/application_card.dart';
import 'widgets/application_details_sheet.dart';
import 'widgets/empty_state.dart';
import 'widgets/loading_shimmer.dart';

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
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
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
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadFavorites(),
      _fetchApplications(),
    ]);
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchApplications() async {
    setState(() => isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('applications')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      setState(() {
        applications = querySnapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList();
        isLoading = false;
        if (applications.isNotEmpty) {
          controller = CardSwiperController();
        }
      });
    } catch (e) {
      print('Error fetching applications: $e');
      setState(() => isLoading = false);
      _showErrorSnackbar('Failed to load applications');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favoriteApplicationIds');

      if (favoriteIds?.isNotEmpty ?? false) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('applications')
            .where(FieldPath.documentId, whereIn: favoriteIds)
            .get();

        setState(() {
          favoriteApplications = querySnapshot.docs
              .map((doc) => Application.fromFirestore(doc))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
      _showErrorSnackbar('Failed to load favorites');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = favoriteApplications.map((a) => a.id).toList();
      await prefs.setStringList('favoriteApplicationIds', favoriteIds);
    } catch (e) {
      print('Error saving favorites: $e');
      _showErrorSnackbar('Failed to save favorites');
    }
  }

  Future<void> _incrementCompanyLikesCount(Application application) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(application.id)
          .update({
        'companyLikesCount': FieldValue.increment(1)
      });
    } catch (e) {
      print('Error incrementing likes: $e');
    }
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (previousIndex >= 0 && previousIndex < applications.length) {
      final currentApplication = applications[previousIndex];

      if (direction == CardSwiperDirection.right) {
        _handleRightSwipe(currentApplication);
      }
      if(direction == CardSwiperDirection.top){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Swipe Right or Left"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if(direction == CardSwiperDirection.bottom){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Swipe Right or Left"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      else if (direction == CardSwiperDirection.left) {
        _handleLeftSwipe(currentApplication);
      }
    }

    if (currentIndex == null || currentIndex >= applications.length) {
      _onEnd();
      return false;
    }
    return true;
  }

  void _handleRightSwipe(Application application) {
    _updateApplicationStatus(application.id, 'Accepted');
    _incrementCompanyLikesCount(application);
    setState(() {
      favoriteApplications.add(application);
      _saveFavorites();
    });
  }

  void _handleLeftSwipe(Application application) {
    _updateApplicationStatus(application.id, 'Rejected');
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
    } catch (e) {
      print('Error updating status: $e');
      _showErrorSnackbar('Failed to update application status');
    }
  }

  void _onEnd() {
    setState(() {
      applications.clear();
      controller = CardSwiperController();
    });
    _fetchApplications();
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAllFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text(
            'Are you sure you want to remove all favorites? This action cannot be undone.'
        ),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _removeFromFavorites(Application application) {
    setState(() {
      favoriteApplications.removeWhere((app) => app.id == application.id);
      _saveFavorites();
    });
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
            children: [
              HomeAppBar(
                favoriteApplications: favoriteApplications,
                onFavoritesTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(
                      favoriteApplications: favoriteApplications,
                      clearAllFavorites: _clearAllFavorites,
                      removeFromFavorites: _removeFromFavorites,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildMainContent(),
              ),
              if (applications.isNotEmpty)
                SwipeActions(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return const LoadingShimmer();
    }

    if (applications.isEmpty) {
      return EmptyState(onRefresh: _fetchApplications);
    }

    return _buildCardSwiper();
  }

  Widget _buildCardSwiper() {
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
            child: ApplicationCard(
              application: applications[index],
              onDetailsPressed: () => _showApplicationDetails(applications[index]),
            ),
          );
        },
      ),
    );
  }

  void _showApplicationDetails(Application application) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ApplicationDetailsSheet(application: application),
    );
  }
}