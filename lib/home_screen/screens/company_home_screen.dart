import 'package:flutter/material.dart';
import 'package:reswipe/home_screen/widgets/custom_button_nav.dart';
import '../../company_pages/company_settings_screen/settings_page.dart';
import '../../company_pages/home_screen/home_page.dart' show HomeScreen;
import '../../company_pages/job_posts/job_posts_screen.dart';
import '../../company_pages/profile/profile_screen.dart';
import '../../models/company_model/applications.dart';

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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        isCompanyNav: true,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}