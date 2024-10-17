import 'package:flutter/material.dart';
import '../company_pages/favourite_screen.dart' show FavoritesScreen;
import '../company_pages/home_page.dart' show HomeScreen;
import '../company_pages/job_post_screen.dart';
import '../company_pages/profile_screen.dart';

class CompanyMainScreen extends StatefulWidget {
  @override
  _CompanyMainScreenState createState() => _CompanyMainScreenState();
}

class _CompanyMainScreenState extends State<CompanyMainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      JobPostsScreen(),
      FavoritesScreen(), // Instantiate the widget
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple, // Match your app's theme
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