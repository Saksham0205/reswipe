import 'package:flutter/material.dart';

class NavBarConfig {
  static const List<({IconData icon, String label})> jobSeekerItems = [
    (icon: Icons.work_rounded, label: 'Jobs'),
    (icon: Icons.history_rounded, label: 'Applications'),
    (icon: Icons.person_rounded, label: 'Profile'),
    (icon: Icons.settings_rounded, label: 'Settings'),
  ];

  static const List<({IconData icon, String label})> companyItems = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.work_rounded, label: 'Jobs'),
    (icon: Icons.settings_rounded, label: 'Settings'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];
}