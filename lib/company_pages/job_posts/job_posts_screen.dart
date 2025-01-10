import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../State_management/company_backend.dart';
import '../../home_screen/screens/company_home_screen.dart';
import '../../models/company_model/job.dart';
import 'components/custom_snackbar.dart';
import 'components/form_sections.dart';
import 'components/navigation_buttons.dart';
import 'components/step_indicator.dart';

class JobPostScreen extends StatelessWidget {
  const JobPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        return const JobPostScreenContent();
      },
    );
  }
}

class JobPostScreenContent extends StatefulWidget {
  const JobPostScreenContent({super.key});

  @override
  _JobPostScreenContentState createState() => _JobPostScreenContentState();
}

class _JobPostScreenContentState extends State<JobPostScreenContent> with TickerProviderStateMixin {
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
  bool _isCheckingJobLimit = true;
  int _currentStep = 0;
  Map<int, bool> _completedSections = {0: false, 1: false, 2: false};
  late FocusNode _titleFocus;
  late FocusNode _descriptionFocus;
  late FocusNode _responsibilitiesFocus;
  late FocusNode _qualificationsFocus;
  late FocusNode _salaryRangeFocus;
  late FocusNode _locationFocus;

  @override
  void initState() {
    super.initState();
    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _responsibilitiesFocus = FocusNode();
    _qualificationsFocus = FocusNode();
    _salaryRangeFocus = FocusNode();
    _locationFocus = FocusNode();
    _setupKeyboardListeners();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _checkJobPostLimit();
    _setupSalaryRangeListener();
  }

  Future<void> _checkJobPostLimit() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final companyId = userDoc.get('companyId');

        final jobsSnapshot = await FirebaseFirestore.instance
            .collection('jobs')
            .where('companyId', isEqualTo: companyId)
            .get();

        setState(() {
          _isCheckingJobLimit = false;
          if (jobsSnapshot.docs.length >= 3) {
            _showJobLimitDialog();
          }
        });
      }
    } catch (e) {
      setState(() => _isCheckingJobLimit = false);
      CustomSnackBar.error(context, 'Error checking job limit: ${e.toString()}');
    }
  }
  void _setupKeyboardListeners() {
    _titleFocus.addListener(() => _onFocusChange(_titleFocus));
    _descriptionFocus.addListener(() => _onFocusChange(_descriptionFocus));
    _responsibilitiesFocus.addListener(() => _onFocusChange(_responsibilitiesFocus));
    _qualificationsFocus.addListener(() => _onFocusChange(_qualificationsFocus));
    _salaryRangeFocus.addListener(() => _onFocusChange(_salaryRangeFocus));
    _locationFocus.addListener(() => _onFocusChange(_locationFocus));
  }
  void _onFocusChange(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      // Scroll to the focused field
      Scrollable.ensureVisible(
        focusNode.context!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
      );
    }
  }
  void _setupSalaryRangeListener() {
    _salaryRangeController.addListener(() {
      if (_salaryRangeController.text.isNotEmpty &&
          !_salaryRangeController.text.toLowerCase().contains('per year') &&
          !_salaryRangeController.text.toLowerCase().contains('per annum')) {
        _salaryRangeController.text = '${_salaryRangeController.text} per year';
      }
    });
  }
  void _showJobLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(
            Icons.warning_rounded,
            color: Colors.deepPurple,
            size: 48,
          ),
          title: Text(
            'Job Posting Limit Reached',
            style: TextStyle(
              color: Colors.deepPurple[700],
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You can only post up to 3 jobs at a time.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please delete an existing job posting before creating a new one.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompanyMainScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'I Understand',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Reset Form?'),
          content: const Text(
              'This will clear all entered information. Are you sure you want to reset the form?'
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() => _currentStep = _tabController.index);
    }
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _responsibilitiesFocus.dispose();
    _qualificationsFocus.dispose();
    _salaryRangeFocus.dispose();
    _locationFocus.dispose();
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
    if (_isCheckingJobLimit) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobError) {
          setState(() => _isLoading = false);
          CustomSnackBar.error(context, state.message);
        }
        if (state is JobsLoaded) {
          _showSuccessAndNavigate();
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
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
                            focusNodes: {
                              'title': _titleFocus,
                              'description': _descriptionFocus,
                              'responsibilities': _responsibilitiesFocus,
                              'qualifications': _qualificationsFocus,
                              'salaryRange': _salaryRangeFocus,
                              'location': _locationFocus,
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
                        onSubmit: _submitForm,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showSuccessAnimation) _buildSuccessOverlay(),
            ],
          ),
        ),
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
      actions: [
        if (_formHasData())
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.refresh),
            onPressed: _showResetConfirmationDialog,
            tooltip: 'Reset Form',
          ),
      ],
    );
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      ) ?? false;
    }
    return true;
  }
  Widget _buildSuccessOverlay() {
    return AnimatedOpacity(
      opacity: _showSuccessAnimation ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
  bool _canProceed() {
    return _completedSections[_currentStep] ?? false;
  }
  void _submitForm() async {
    if (!_formKey.currentState!.validate() || !_canProceed()) {
      CustomSnackBar.error(context, 'Please fill in all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final job = Job(
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
        companyId: '',  // Will be set in bloc
        companyName: '', // Will be set in bloc
      );

      context.read<JobBloc>().add(AddJob(job));
    } catch (e) {
      setState(() => _isLoading = false);
      CustomSnackBar.error(context, 'Error submitting job: ${e.toString()}');
    }
  }
  Future<void> _showSuccessAndNavigate() async {
    setState(() {
      _isLoading = false;
      _showSuccessAnimation = true;
    });

    try {
      await _successAnimationController.forward();
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        _successAnimationController.reset();
        setState(() {
          _showSuccessAnimation = false;
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const CompanyMainScreen(),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showSuccessAnimation = false;
        });
        CustomSnackBar.error(context, 'Navigation error occurred');
      }
    }
  }
  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _responsibilitiesController.clear();
      _qualificationsController.clear();
      _salaryRangeController.clear();
      _locationController.clear();
      _employmentType = 'Full-time';
      _currentStep = 0;
      _completedSections = {0: false, 1: false, 2: false};
      _tabController.animateTo(0);
      _showSuccessAnimation = false;
      _isLoading = false;
    });
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