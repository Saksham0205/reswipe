import 'package:flutter/material.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _issueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _issueController.dispose();
    _animationController.dispose();
    super.dispose();
  }


  Future<void> _submitIssue() async {
    // ... (keep existing submit logic)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
          tabs: const [
            Tab(
              icon: Icon(Icons.question_answer),
              text: 'FAQs',
            ),
            Tab(
              icon: Icon(Icons.support_agent),
              text: 'Support',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFAQTab(),
              _buildSupportTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTab() {
    List<Map<String, dynamic>> filteredCategories = getFAQCategories().map((category) {
      // Filter FAQs that match the search query
      List<Map<String, String>> filteredFaqs = (category['faqs'] as List).where((faq) {
        String question = faq['question']!.toLowerCase();
        String answer = faq['answer']!.toLowerCase();
        return question.contains(_searchQuery) || answer.contains(_searchQuery);
      }).cast<Map<String, String>>().toList();

      // Return category with filtered FAQs
      return {
        'title': category['title'],
        'faqs': filteredFaqs,
      };
    }).where((category) => (category['faqs'] as List).isNotEmpty).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 24),
        if (filteredCategories.isEmpty && _searchQuery.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No FAQs found matching "$_searchQuery"',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ...filteredCategories.map((category) => _buildFAQCategory(category)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search FAQs...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey[600]),
          hintStyle: TextStyle(color: Colors.grey[400]),
          // Add a clear button when there's text
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildFAQCategory(Map<String, dynamic> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            category['title'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple[700],
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...category['faqs'].map<Widget>((faq) => _buildFAQItem(faq)),
      ],
    );
  }

  Widget _buildFAQItem(Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            faq['question']!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                faq['answer']!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildContactHeader(),
        const SizedBox(height: 24),
        _buildSupportForm(),
        const SizedBox(height: 32),
        _buildContactOptions(),
      ],
    );
  }

  Widget _buildContactHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need Help?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We\'re here to help you with any questions or issues you might have.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit a Support Request',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _issueController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe your issue or question...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe your issue';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitIssue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Submit Request',
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

  Widget _buildContactOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other Ways to Reach Us',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 16),
        ..._buildContactCards(),
      ],
    );
  }

  List<Widget> _buildContactCards() {
    final contactInfo = [
      {
        'icon': Icons.email_outlined,
        'title': 'Email',
        'subtitle': 'ajnabee.care@gmail.com',
        'color': Colors.blue,
      },
      {
        'icon': Icons.schedule_outlined,
        'title': 'Working Hours',
        'subtitle': 'Monday - Friday, 9:00 AM - 6:00 PM IST',
        'color': Colors.orange,
      },
    ];

    return contactInfo.map((info) => _buildContactCard(info)).toList();
  }

  Widget _buildContactCard(Map<String, dynamic> info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (info['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            info['icon'] as IconData,
            color: info['color'] as Color,
          ),
        ),
        title: Text(
          info['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          info['subtitle'] as String,
          style: TextStyle(
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getFAQCategories() {
    return [
      {
        'title': 'Getting Started',
        'faqs': [
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
      },
      {
        'title': 'Account Management',
        'faqs': [
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
      },
      {
        'title': 'Features & Usage',
        'faqs': [
          {
            'question': 'Can I undo a swipe?',
            'answer':
            'Yes, premium users can undo their last swipe by tapping the undo button.',
          },
        ],
      },
    ];
  }
}