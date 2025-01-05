import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../State_management/Company_state.dart';
import '../../models/company_model/job.dart';
import 'components/custom_snackbar.dart';
import 'components/form_sections.dart';
import 'components/navigation_buttons.dart';
import 'components/step_indicator.dart';

class JobPostScreen extends StatefulWidget {
  @override
  _JobPostScreenState createState() => _JobPostScreenState();
}

class _JobPostScreenState extends State<JobPostScreen> with TickerProviderStateMixin {
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
      duration: Duration(seconds: 2),
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
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobError) {
          CustomSnackBar.error(context, state.message);
        }
        if (state is JobsLoaded) {
          _showSuccessAndNavigate();
        }
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
                        padding: EdgeInsets.all(16),
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
                      onSubmit: _submitForm,
                    ),
                  ],
                ),
              ),
            ),
            if (_showSuccessAnimation)
              _buildSuccessOverlay(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Post a New Job',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
      elevation: 0,
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
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
                _successAnimationController.forward();
              },
            ),
            SizedBox(height: 20),
            Text(
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

  void _submitForm() {
    if (!_formKey.currentState!.validate() || !_canProceed()) {
      CustomSnackBar.error(context, 'Please fill in all required fields');
      return;
    }

    setState(() => _isLoading = true);

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
  }

  Future<void> _showSuccessAndNavigate() async {
    setState(() {
      _isLoading = false;
      _showSuccessAnimation = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
      context.read<JobBloc>().add(LoadJobs());
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