import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../../models/company_model/job.dart';
import '../../services/firestore_service.dart';
import 'components/custom_snackbar.dart';
import 'components/form_sections.dart';
import 'components/navigation_buttons.dart';
import 'components/step_indicator.dart';
class JobPostsScreen extends StatefulWidget {
  @override
  _JobPostsScreenState createState() => _JobPostsScreenState();
}

class _JobPostsScreenState extends State<JobPostsScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _salaryRangeController = TextEditingController();
  final _locationController = TextEditingController();
  String _employmentType = 'Full-time';
  late AnimationController _successAnimationController;
  bool _showSuccessAnimation = false;
  late TabController _tabController;
  bool _isLoading = false;
  int _currentStep = 0;
  Map<int, bool> _completedSections = {0: false, 1: false, 2: false};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _successAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop();
      }
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() => _currentStep = _tabController.index);
    }
  }

  @override
  void dispose() {
    _successAnimationController.dispose();
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _responsibilitiesController.dispose();
    _qualificationsController.dispose();
    _salaryRangeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: _buildAppBar(),
            body: Form(
              key: _formKey,
              child: Column(
                children: [
                  StepIndicator(
                    currentStep: _currentStep,
                    completedSections: _completedSections,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: FormSections(
                        currentStep: _currentStep,
                        controllers: {
                          'title': _titleController,
                          'description': _descriptionController,
                          'responsibilities': _responsibilitiesController,
                          'qualifications': _qualificationsController,
                          'salaryRange': _salaryRangeController,
                          'location': _locationController,
                        },
                        employmentType: _employmentType,
                        onEmploymentTypeChanged: (value) =>
                            setState(() => _employmentType = value),
                        onFieldChanged: _validateCurrentSection,
                      ),
                    ),
                  ),
                  NavigationButtons(
                    currentStep: _currentStep,
                    isLoading: _isLoading,
                    canProceed: _canProceed(),
                    onPrevious: _handlePrevious,
                    onNext: _handleNext,
                    onSubmit: () => _submitForm(context),
                  ),
                ],
              ),
            ),
          ),
          if (_showSuccessAnimation)
            Container(
              color: Colors.white,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/success.json',

                      controller: _successAnimationController,
                      width: 200,
                      height: 200,
                      onLoaded: (composition) {
                        _successAnimationController.forward();
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Job Posted Successfully!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Post a New Job',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
      elevation: 0,
    );
  }

  void _handlePrevious() {
    setState(() {
      _currentStep--;
      _tabController.animateTo(_currentStep);
    });
  }

  void _handleNext() {
    if (_completedSections[_currentStep] == true) {
      setState(() {
        _currentStep++;
        _tabController.animateTo(_currentStep);
      });
    }
  }

// This function updates the state
  void _validateCurrentSection() {
    setState(() {
      switch (_currentStep) {
        case 0:
          _completedSections[_currentStep] = _titleController.text.isNotEmpty &&
              _descriptionController.text.isNotEmpty;
          break;
        case 1:
          _completedSections[_currentStep] = _responsibilitiesController.text.isNotEmpty &&
              _qualificationsController.text.isNotEmpty;
          break;
        case 2:
          _completedSections[_currentStep] = _salaryRangeController.text.isNotEmpty &&
              _locationController.text.isNotEmpty;
          break;
      }
    });
  }

// This function returns the validation result
  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _titleController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty;
      case 1:
        return _responsibilitiesController.text.isNotEmpty &&
            _qualificationsController.text.isNotEmpty;
      case 2:
        return _salaryRangeController.text.isNotEmpty &&
            _locationController.text.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate() || !_canProceed()) {
      CustomSnackBar.error(context, 'Please fill in all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        CustomSnackBar.error(context, 'Please log in to post a job');
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      String companyId = userDoc.get('companyId') ?? '';
      String companyName = userDoc.get('companyName') ?? '';

      if (companyId.isEmpty || companyName.isEmpty) {
        CustomSnackBar.error(
            context, 'Company information is missing. Please update your profile.');
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
      _resetForm();

      // Show success animation
      setState(() {
        _isLoading = false;
        _showSuccessAnimation = true;
      });

      // Wait for animation to complete (assuming animation is 2 seconds)
      await Future.delayed(const Duration(seconds: 2));

      // Navigate back to job posts screen
      if (mounted) {
        // Navigator.of(context).pushReplacementNamed('/company/jobs');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => JobPostsScreen()),
        );
      }

    } catch (e) {
      CustomSnackBar.error(context, 'Error posting job: ${e.toString()}');
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

  Future<bool> _onWillPop() async {
    if (_formHasData()) {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Discard Changes?'),
          content: const Text('Are you sure you want to discard your progress?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Discard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
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
}