import 'package:flutter/material.dart';
import '../../user_pages/applications_page.dart';
import '../../user_pages/home_page/job_listings_page.dart';
import '../../user_pages/profile_page.dart';
import '../../user_pages/user_settings_screen/user_settings_page.dart';
import '../widgets/custom_button_nav.dart';
class JobSeekerHomeScreen extends StatefulWidget {
  @override
  _JobSeekerHomeScreenState createState() => _JobSeekerHomeScreenState();
}

class _JobSeekerHomeScreenState extends State<JobSeekerHomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      JobListingsPage(),
      ApplicationsPage(),
      ProfileScreen(),
      UserSettingsPage(),
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