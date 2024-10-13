import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reswipe/company_pages/favourite_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../models/user_model/applicant.dart';



class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

  class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
    List<Applicant> applicants = [];
    List<Applicant> favoriteApplicants = [];
    late CardSwiperController controller;
    late AnimationController _animationController;
    late Animation<double> _animation;

    @override
    void initState() {
      super.initState();
      controller = CardSwiperController();
      _loadFavorites();
      _fetchApplicants();

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

    Future<void> _fetchApplicants() async {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('applicants').get();
        setState(() {
          applicants = querySnapshot.docs.map((doc) => Applicant.fromFirestore(doc)).toList();
        });
      } catch (e) {
        print('Error fetching applicants: $e');
        // Handle error (show a snackbar, for example)
      }
    }

    Future<void> _loadFavorites() async {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? favoriteIds = prefs.getStringList('favoriteApplicantIds');
      if (favoriteIds != null && favoriteIds.isNotEmpty) {
        try {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('applicants')
              .where(FieldPath.documentId, whereIn: favoriteIds)
              .get();
          setState(() {
            favoriteApplicants = querySnapshot.docs.map((doc) => Applicant.fromFirestore(doc)).toList();
          });
        } catch (e) {
          print('Error loading favorite applicants: $e');
          // Handle error
        }
      }
    }

    Future<void> _saveFavorites() async {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favoriteIds = favoriteApplicants.map((a) => a.id).toList();
      await prefs.setStringList('favoriteApplicantIds', favoriteIds);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: applicants.isEmpty
                    ? _buildLoadingShimmer()
                    : _buildCardSwiper(),
              ),
              _buildSwipeActions(),
            ],
          ),
        ),
      );
    }

    Widget _buildAppBar() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reswipe',
              style: GoogleFonts.pacifico(
                fontSize: 28,
                color: Colors.deepPurple,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(
                    ),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.favorite, color: Colors.deepPurple, size: 32),
                  if (favoriteApplicants.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${favoriteApplicants.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildLoadingShimmer() {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    Widget _buildCardSwiper() {
      return FadeTransition(
        opacity: _animation,
        child: CardSwiper(
          controller: controller,
          cardsCount: favoriteApplicants.length,
          onSwipe: _onSwipe,
          padding: const EdgeInsets.all(24.0),
          cardBuilder: (context, index, _, __) => _buildCard(favoriteApplicants[index]),
        ),
      );
    }

    Widget _buildCard(Applicant applicant) {
      return Hero(
        tag: 'applicant_${applicant.id}',
        child: Card(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      applicant.profilePhotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.person, size: 100, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant.name,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          applicant.jobProfile,
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _viewResume(applicant),
                              icon: Icon(Icons.description, color: Colors.white),
                              label: Text('View Resume', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline, color: Colors.deepPurple),
                              onPressed: () => _showApplicantDetails(applicant),
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
        ),
      );
    }

    bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
      if (direction == CardSwiperDirection.right) {
        setState(() {
          favoriteApplicants.add(applicants[previousIndex]);
          _saveFavorites();
        });
      }
      if (currentIndex == null) {
        _fetchApplicants();
        return false;
      }
      return true;
    }

    void _viewResume(Applicant applicant) {
      // Implement resume viewing logic
      // You might want to use a package like url_launcher to open the PDF
    }

    void _showApplicantDetails(Applicant applicant) {
      // Implement a modal or navigate to a new screen to show more applicant details
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
              icon: Icons.favorite,
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
  }