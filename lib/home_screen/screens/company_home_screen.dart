import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reswipe/home_screen/widgets/custom_button_nav.dart';
import '../../State_management/Company_state.dart';
import '../../company_pages/company_settings_screen/settings_page.dart';
import '../../company_pages/home_screen/home_page.dart' show HomeScreen;
import '../../company_pages/job_posts/job_posts_screen.dart';
import '../../company_pages/profile/profile_screen.dart';

class CompanyMainScreen extends StatefulWidget {
  const CompanyMainScreen({super.key});

  @override
  _CompanyMainScreenState createState() => _CompanyMainScreenState();
}

class _CompanyMainScreenState extends State<CompanyMainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  late JobBloc _jobBloc;

  @override
  void initState() {
    super.initState();
    // Get the JobBloc instance from the parent context
    _jobBloc = BlocProvider.of<JobBloc>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the entire screen with BlocProvider.value
    return BlocProvider.value(
      value: _jobBloc,
      child: Builder(
        builder: (context) {
          _screens = [
            const HomeScreen(),
            JobPostScreen(),
            CompanySettingsPage(),
            ProfileScreen(),
          ];

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
        },
      ),
    );
  }
}