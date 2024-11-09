import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'About Reswipe',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Purple Header Section
            Container(
              color: Colors.deepPurpleAccent,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.document_scanner_outlined,
                        size: 50,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Reswipe v1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Simplifying Resume Screening',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Sections
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('About Reswipe'),
                  const SizedBox(height: 10),
                  _buildSectionContent(
                    'Reswipe is an innovative application designed to simplify resume screening, bringing speed and precision to the job recruitment process. Built under Ajnabee, Reswipe leverages smart algorithms to quickly identify suitable candidates by swiping through resumes.',
                  ),

                  const SizedBox(height: 25),
                  _buildSectionTitle('Key Features'),
                  const SizedBox(height: 10),
                  _buildFeatureItem(Icons.speed, 'Quick Screening', 'Screen resumes with simple swipe gestures'),
                  _buildFeatureItem(Icons.psychology, 'Smart Matching', 'AI-powered candidate matching algorithms'),
                  _buildFeatureItem(Icons.analytics, 'Analytics', 'Detailed insights and screening metrics'),
                  _buildFeatureItem(Icons.cloud_sync, 'Cloud Sync', 'Access your data across devices'),

                  const SizedBox(height: 25),
                  _buildSectionTitle('About Ajnabee'),
                  const SizedBox(height: 10),
                  _buildSectionContent(
                    'Ajnabee, the parent company of Reswipe, focuses on cutting-edge digital solutions in recruitment, fashion, and technology. Through Ajnabee, we aim to provide smart, user-friendly apps to solve real-world challenges.',
                  ),

                  const SizedBox(height: 25),
                  _buildSectionTitle('Contact Us'),
                  const SizedBox(height: 10),
                  _buildContactItem(Icons.email, 'ajnabee.care@gmail.com'),
                  _buildContactItem(Icons.language, 'www.ajnabee.in'),
                  _buildContactItem(Icons.location_on, 'New Delhi, India'),

                  const SizedBox(height: 30),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Powered by Ajnabee',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '© 2024 All rights reserved',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurpleAccent,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.deepPurpleAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.deepPurpleAccent,
            size: 20,
          ),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}