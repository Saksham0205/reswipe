import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _issueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  String getUserEmail() {
    return "sakshamchauhan02@outlook.com";
  }

  Future<void> _submitIssue() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final String userEmail = getUserEmail();
        // Encode the email components properly
        final String subject = Uri.encodeComponent('Support Request from Reswipe App');
        final String body = Uri.encodeComponent(
            'From: $userEmail\n\nIssue Description:\n${_issueController.text}');

        // Construct the mailto URL
        final String mailtoUrl =
            'mailto:ajnabee.care@gmail.com?subject=$subject&body=$body';

        if (await canLaunchUrl(Uri.parse(mailtoUrl))) {
          await launchUrl(Uri.parse(mailtoUrl));
          _issueController.clear();
          if (mounted) {  // Check if widget is still mounted
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you for reaching out. We\'ll get back to you soon!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {  // Check if widget is still mounted
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open email client. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {  // Check if widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send support request. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {  // Check if widget is still mounted
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.help_outline),
              text: 'Help',
            ),
            Tab(
              icon: Icon(Icons.support_agent),
              text: 'Support',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Help Tab
          SingleChildScrollView(
            child: Column(
              children: [
                // _buildHelpHeader(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildFAQCategory(
                        'Getting Started',
                        [
                          {
                            'question': 'How do I create an account?',
                            'answer':
                            'To create an account, click on the "Sign Up" button on the login screen and follow the prompts. You\'ll need to provide your email address and create a password.',
                          },
                          {
                            'question': 'How does resume swiping work?',
                            'answer':
                            'Swipe right on resumes you like and left on those you want to pass. The app will learn from your preferences to show better matches over time.',
                          },
                        ],
                      ),
                      _buildFAQCategory(
                        'Account Management',
                        [
                          {
                            'question': 'How do I reset my password?',
                            'answer':
                            'Click on "Forgot Password" on the login screen and follow the instructions sent to your email to reset your password.',
                          },
                          {
                            'question': 'How can I update my profile?',
                            'answer':
                            'Go to Settings > Profile to update your personal information and preferences.',
                          },
                        ],
                      ),
                      _buildFAQCategory(
                        'Features & Usage',
                        [
                          {
                            'question': 'Can I undo a swipe?',
                            'answer':
                            'Yes, premium users can undo their last swipe by tapping the undo button.',
                          },
                          {
                            'question': 'How do I export my matched candidates?',
                            'answer':
                            'Go to Matches > Export and choose your preferred format (PDF or Excel) to download your matched candidates list.',
                          },
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Support Tab
          SingleChildScrollView(
            child: Column(
              children: [
                // _buildSupportHeader(),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit a Support Request',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        SizedBox(height: 20.sp),
                        TextFormField(
                          controller: _issueController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Describe your issue or question...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:  BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 2.w,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please describe your issue';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitIssue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                :  Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          'Other Ways to Reach Us',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        _buildContactCard(
                          icon: Icons.email,
                          title: 'Email',
                          subtitle: 'ajnabee.care@gmail.com',
                        ),
                        _buildContactCard(
                          icon: Icons.phone,
                          title: 'Phone',
                          subtitle: '+91 8376063400',
                        ),
                        _buildContactCard(
                          icon: Icons.schedule,
                          title: 'Working Hours',
                          subtitle: 'Monday - Friday, 9:00 AM - 6:00 PM IST',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCategory(String title, List<Map<String, String>> faqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurpleAccent,
            ),
          ),
        ),
        ...faqs.map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        children: [
          Padding(
            padding:EdgeInsets.all(16.w),
            child: Text(
              answer,
              style:TextStyle(fontSize: 15.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.deepPurpleAccent,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}