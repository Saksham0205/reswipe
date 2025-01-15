import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../backend/user_backend.dart';
import '../../user_pages/applications_page.dart';
import '../../user_pages/home_page/job_listings_page.dart';
import '../../user_pages/profile_page.dart';
import '../../user_pages/user_settings_screen/user_settings_page.dart';
import '../widgets/custom_button_nav.dart';

class JobSeekerHomeScreen extends StatefulWidget {
  const JobSeekerHomeScreen({super.key});

  @override
  _JobSeekerHomeScreenState createState() => _JobSeekerHomeScreenState();
}

class _JobSeekerHomeScreenState extends State<JobSeekerHomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = BlocProvider.of<ProfileBloc>(context, listen: false);
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _profileBloc.userBackend.initialize(user.uid);
      _profileBloc.add(LoadProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: Builder(
        builder: (context) {
          _screens = [
             JobListingsPage(),
             ApplicationsPage(),
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProfileLoaded) {
                  return ProfilePage(
                    initialData: state.profile,
                    userBackend: context.read<ProfileBloc>().userBackend,
                  );
                } else if (state is ProfileError) {
                  return _buildErrorScreen(context, state.message);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
             UserSettingsPage(),
          ];

          return Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _screens[_currentIndex],
            ),
            bottomNavigationBar: CustomBottomNavBar(
              isCompanyNav: false,
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

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $message',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _initializeProfile();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
