import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_model/job.dart';
import '../services/firestore_service.dart';

class JobPostsScreen extends StatefulWidget {
  @override
  _JobPostsScreenState createState() => _JobPostsScreenState();
}

class _JobPostsScreenState extends State<JobPostsScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _salaryRangeController = TextEditingController();
  final _locationController = TextEditingController();
  String _employmentType = 'Full-time';

  // Animation controllers
  late TabController _tabController;
  bool _isLoading = false;
  int _currentStep = 0;

  // Section completion tracking
  Map<int, bool> _completedSections = {0: false, 1: false, 2: false};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentStep = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _responsibilitiesController.dispose();
    _qualificationsController.dispose();
    _salaryRangeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Helper function to show error messages with animation
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.easeInOut,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show success message with animation
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  // Validate current section
  bool _validateCurrentSection() {
    switch (_currentStep) {
      case 0: // Basic Information
        return _titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty;
      case 1: // Details
        return _responsibilitiesController.text.isNotEmpty &&
            _qualificationsController.text.isNotEmpty;
      case 2: // Requirements
        return _salaryRangeController.text.isNotEmpty &&
            _locationController.text.isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          bool isActive = index == _currentStep;
          bool isCompleted = _completedSections[index] ?? false;
          return Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green
                      : (isActive ? Colors.blue : Colors.grey[300]),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Container(
                  width: 50,
                  height: 2,
                  color: _completedSections[index] ?? false
                      ? Colors.green
                      : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return AnimatedOpacity(
      opacity: _currentStep == 0 ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedTextField(
            controller: _titleController,
            label: 'Job Title',
            icon: Icons.work,
          ),
          SizedBox(height: 16),
          _buildAnimatedTextField(
            controller: _descriptionController,
            label: 'Job Description',
            icon: Icons.description,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return AnimatedOpacity(
      opacity: _currentStep == 1 ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedTextField(
            controller: _responsibilitiesController,
            label: 'Responsibilities',
            icon: Icons.list,
            maxLines: 5,
            hint: 'Enter key responsibilities (one per line)',
          ),
          SizedBox(height: 16),
          _buildAnimatedTextField(
            controller: _qualificationsController,
            label: 'Qualifications',
            icon: Icons.school,
            maxLines: 5,
            hint: 'Enter required qualifications (one per line)',
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return AnimatedOpacity(
      opacity: _currentStep == 2 ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _salaryRangeController,
                  label: 'Salary Range',
                  icon: Icons.attach_money,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildEmploymentTypeDropdown(),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? hint,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) {
          setState(() {
            _completedSections[_currentStep] = _validateCurrentSection();
          });
        },
      ),
    );
  }

  Widget _buildEmploymentTypeDropdown() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: DropdownButtonFormField<String>(
        value: _employmentType,
        decoration: InputDecoration(
          labelText: 'Employment Type',
          prefixIcon: Icon(Icons.business_center),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: ['Full-time', 'Part-time', 'Contract', 'Internship']
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _employmentType = newValue!;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post a New Job'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IndexedStack(
                      index: _currentStep,
                      children: [
                        _buildBasicInfoSection(),
                        _buildDetailsSection(),
                        _buildRequirementsSection(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton.icon(
              icon: Icon(Icons.arrow_back),
              label: Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                setState(() {
                  _currentStep--;
                  _tabController.animateTo(_currentStep);
                });
              },
            )
          else
            SizedBox(width: 0),
          _currentStep < 2
              ? ElevatedButton.icon(
            icon: Icon(Icons.arrow_forward),
            label: Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: _validateCurrentSection()
                ? () {
              setState(() {
                _completedSections[_currentStep] = true;
                _currentStep++;
                _tabController.animateTo(_currentStep);
              });
            }
                : null,
          )
              : ElevatedButton.icon(
            icon: _isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Icon(Icons.check),
            label: Text(_isLoading ? 'Posting...' : 'Post Job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: _isLoading ? null : () => _submitForm(context),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate() || !_validateCurrentSection()) {
      _showErrorSnackBar(context, 'Please fill in all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        String companyId = userDoc.get('companyId') ?? '';
        String companyName = userDoc.get('companyName') ?? '';

        if (companyId.isEmpty || companyName.isEmpty) {
          _showErrorSnackBar(
              context, 'Company information is missing. Please update your profile.');
          setState(() => _isLoading = false);
          return;
        }

        Job newJob = Job(
            title: _titleController.text.trim(),
    description: _descriptionController.text.trim(),
    responsibilities: _responsibilitiesController.text
    .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList(),
    qualifications: _qualificationsController.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList(),
    salaryRange: _salaryRangeController.text.trim(),
    location: _locationController.text.trim(),
    employmentType: _employmentType,
    companyId: companyId,
          companyName: companyName,
        );

        await AuthService().addJob(newJob);

        // Reset form and show success message
        _formKey.currentState!.reset();
        _resetForm();
        _showSuccessSnackBar(context, 'Job posted successfully!');

        // Optional: Navigate back or to a success screen
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar(context, 'Please log in to post a job');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error posting job: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _responsibilitiesController.clear();
    _qualificationsController.clear();
    _salaryRangeController.clear();
    _locationController.clear();
    _employmentType = 'Full-time';
    setState(() {
      _currentStep = 0;
      _completedSections = {0: false, 1: false, 2: false};
      _tabController.animateTo(0);
    });
  }

  // Custom dialog to confirm form reset
  Future<bool> _onWillPop() async {
    if (_formHasData()) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Discard Changes?'),
          content: Text('Are you sure you want to discard your progress?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: Text('Discard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ) ?? false;
    }
    return true;
  }

  bool _formHasData() {
    return _titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _responsibilitiesController.text.isNotEmpty ||
        _qualificationsController.text.isNotEmpty ||
        _salaryRangeController.text.isNotEmpty ||
        _locationController.text.isNotEmpty ||
        _employmentType != 'Full-time';
  }

  // Add a helper method to show tooltips
  Widget _buildTooltip(Widget child, String message) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(color: Colors.white),
      child: child,
    );
  }

  // Add animations for section transitions
  Widget _buildAnimatedSection(Widget child) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Add a progress indicator
  Widget _buildProgressIndicator() {
    final progress = (_currentStep + 1) / 3;
    return Container(
      height: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // Add a section header with animation
  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  // Add help text with expandable details
  Widget _buildHelpText(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }
}