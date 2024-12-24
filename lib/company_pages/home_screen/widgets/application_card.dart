import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/company_model/applications.dart';
import 'card_pages/first_page.dart';
import 'card_pages/second_page.dart';
import 'card_pages/third_page.dart';

class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback onDetailsPressed;

  const ApplicationCard({
    Key? key,
    required this.application,
    required this.onDetailsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PageView(
          controller: pageController,
          children: [
            FirstPage(
              application: application,
              onResumeView: () => _viewResume(context),
              onDetailsPressed: onDetailsPressed,
            ),
            SecondPage(application: application),
            ThirdPage(application: application),
          ],
        ),
      ),
    );
  }

  void _viewResume(BuildContext context) {
    if (application.resumeUrl.isNotEmpty) {
      launchUrl(Uri.parse(application.resumeUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resume not available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}