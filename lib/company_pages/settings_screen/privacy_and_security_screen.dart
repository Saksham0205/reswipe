import 'package:flutter/material.dart';

class PrivacyAndSecurityScreen extends StatelessWidget {
  const PrivacyAndSecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy & Security',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Data Collection',
                    'We collect and process the following information:',
                    [
                      'Profile information (name, email, professional details)',
                      'Resume data and preferences',
                      'Usage statistics and interaction data',
                      'Device information and app analytics',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'How We Use Your Data',
                    'Your data is used to:',
                    [
                      'Improve resume matching algorithms',
                      'Enhance user experience',
                      'Provide personalized recommendations',
                      'Maintain app security and prevent fraud',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Data Security',
                    'We implement the following security measures:',
                    [
                      'End-to-end encryption for sensitive data',
                      'Regular security audits and updates',
                      'Secure cloud storage with redundancy',
                      'Industry-standard authentication protocols',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Your Rights',
                    'You have the right to:',
                    [
                      'Access your personal data',
                      'Request data modification or deletion',
                      'Opt-out of data collection',
                      'Export your data in a portable format',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPrivacyControls(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.deepPurpleAccent,
      padding: const EdgeInsets.all(20),
      child: const Column(
        children: [
          Icon(
            Icons.security,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 15),
          Text(
            'Your Privacy Matters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'We are committed to protecting your data',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildListItem(item)),
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.deepPurpleAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyControls(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Controls',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 16),
            _buildPrivacyControl(
              'Data Collection',
              'Allow data collection for improved matching',
              true,
            ),
            const Divider(),
            _buildPrivacyControl(
              'Analytics',
              'Share anonymous usage data',
              true,
            ),
            const Divider(),
            _buildPrivacyControl(
              'Marketing',
              'Receive personalized recommendations',
              false,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement data export functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your data export request has been initiated.'),
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Export My Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyControl(String title, String subtitle, bool defaultValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SwitchListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          value: defaultValue,
          activeColor: Colors.deepPurpleAccent,
          onChanged: (bool value) {
            // Implement the privacy control toggle functionality
            setState(() {
              // Update the privacy setting
            });
          },
        );
      },
    );
  }
}