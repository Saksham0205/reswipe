import 'package:flutter/material.dart';
import '../company_pages/company_settings_screen/settings_page.dart';
import '../company_pages/home_screen/home_page.dart' show HomeScreen;
import '../company_pages/job_posts/job_posts_screen.dart';
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
      CompanySettingsPage(),
      ProfileScreen(),
    ];
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
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Job Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}