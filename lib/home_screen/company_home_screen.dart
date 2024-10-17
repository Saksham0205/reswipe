import 'package:flutter/material.dart';
import '../company_pages/favourite_screen.dart' show FavoritesScreen;
import '../company_pages/home_page.dart' show HomeScreen;
import '../company_pages/job_post_screen.dart';
import '../company_pages/profile_screen.dart';
import '../models/company_model/applications.dart';

class CompanyMainScreen extends StatefulWidget {
  @override
  _CompanyMainScreenState createState() => _CompanyMainScreenState();
}

class _CompanyMainScreenState extends State<CompanyMainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  List<Application> _favoriteApplications = [];

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      JobPostsScreen(),
      FavoritesScreen(
        favoriteApplications: _favoriteApplications,
        clearAllFavorites: _clearAllFavorites,
        removeFromFavorites: _removeFromFavorites,
      ),
      ProfileScreen(),
    ];
  }

  void _addToFavorites(Application application) {
    setState(() {
      if (!_favoriteApplications.contains(application)) {
        _favoriteApplications.add(application);
      }
    });
  }

  void _removeFromFavorites(Application application) {
    setState(() {
      _favoriteApplications.remove(application);
    });
  }

  void _clearAllFavorites() {
    setState(() {
      _favoriteApplications.clear();
    });
  }

  void _updateScreens() {
    setState(() {
      _screens[2] = FavoritesScreen(
        favoriteApplications: _favoriteApplications,
        clearAllFavorites: _clearAllFavorites,
        removeFromFavorites: _removeFromFavorites,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 2) {
              _updateScreens();
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Job Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}