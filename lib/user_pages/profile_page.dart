import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../backend/user_backend.dart';
import '../models/user_model/profile_data.dart';

class ProfilePage extends StatelessWidget {
  final ProfileData initialData;
  final UserBackend userBackend;

  const ProfilePage({
    Key? key,
    required this.initialData,
    required this.userBackend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileView(initialData: initialData);
  }
}

class ProfileView extends StatefulWidget {
  final ProfileData initialData;

  const ProfileView({
    Key? key,
    required this.initialData,
  }) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _collegeController;
  late final TextEditingController _sessionController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _jobProfileController;
  late final TextEditingController _skillsController;
  late final TextEditingController _experienceController;
  late final TextEditingController _projectsController;
  late final TextEditingController _achievementsController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _updateControllersWithProfile(widget.initialData);
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _collegeController = TextEditingController();
    _sessionController = TextEditingController();
    _qualificationController = TextEditingController();
    _jobProfileController = TextEditingController();
    _skillsController = TextEditingController();
    _experienceController = TextEditingController();
    _projectsController = TextEditingController();
    _achievementsController = TextEditingController();
  }

  void _updateControllersWithProfile(ProfileData profile) {
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _collegeController.text = profile.college;
    _sessionController.text = profile.collegeSession;
    _qualificationController.text = profile.qualification;
    _jobProfileController.text = profile.jobProfile;
    _skillsController.text = profile.skills;
    _experienceController.text = profile.getExperienceText();
    _projectsController.text = profile.getProjectsText();
    _achievementsController.text = profile.getAchievementsText();
  }

  Future<void> _pickAndUploadResume(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        context.read<ProfileBloc>().add(UploadResume(file));
      }
    } catch (e) {
      _showErrorSnackBar('Error picking resume: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          _showErrorSnackBar(state.message);
        } else if (state is ProfileLoaded) {
          _updateControllersWithProfile(state.profile);
          if (_isEditing) {
            setState(() => _isEditing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile updated successfully'),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Text(
              'Professional Profile',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            actions: [
              if (!_isEditing)
                TextButton(
                  onPressed: _toggleEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 4),
                      Text('Edit', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                )
              else
                TextButton(
                  onPressed: _handleSave,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.save_outlined, size: 20),
                      SizedBox(width: 4),
                      Text('Save', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
            ],
          ),
          body: Stack(
            children: [
              _buildProfileContent(),
              if (state is ProfileLoading)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                _nameController.text.isNotEmpty ? _nameController.text[0] : 'U',
                style: TextStyle(
                  fontSize: 48,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isEditing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                controller: _nameController,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          ] else
            Text(
              _nameController.text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          const SizedBox(height: 8),
          if (_isEditing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                controller: _jobProfileController,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                decoration: InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          ] else
            Text(
              _jobProfileController.text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _pickAndUploadResume(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text(
              'Upload Resume',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Contact Information',
            icon: Icons.contact_mail_outlined,
            child: _buildContactInfo(),
          ),
          _buildSectionCard(
            title: 'About',
            icon: Icons.person_outline,
            child: _buildAbout(),
          ),
          _buildSectionCard(
            title: 'Experience',
            icon: Icons.work_outline,
            child: _buildExperience(),
          ),
          _buildSectionCard(
            title: 'Education',
            icon: Icons.school_outlined,
            child: _buildEducation(),
          ),
          _buildSectionCard(
            title: 'Skills',
            icon: Icons.psychology_outlined,
            child: _buildSkills(),
          ),
          _buildSectionCard(
            title: 'Projects',
            icon: Icons.assignment_outlined,
            child: _buildProjects(),
          ),
          _buildSectionCard(
            title: 'Achievements',
            icon: Icons.emoji_events_outlined,
            child: _buildAchievements(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return _isEditing
        ? TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email Address',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.email_outlined),
      ),
    )
        : Row(
      children: [
        Icon(Icons.email_outlined,
            color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(
          _emailController.text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAbout() {
    return _isEditing
        ? TextFormField(
      controller: _qualificationController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'About Me',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: 'Write a summary about yourself...',
      ),
    )
        : Text(
      _qualificationController.text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }

  Widget _buildExperience() {
    return _isEditing
        ? TextFormField(
      controller: _experienceController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Professional Experience',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: 'Add your work experience...',
      ),
    )
        : Text(
      _experienceController.text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }

  Widget _buildEducation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isEditing) ...[
          TextFormField(
            controller: _collegeController,
            decoration: InputDecoration(
              labelText: 'Institution',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _sessionController,
            decoration: InputDecoration(
              labelText: 'Duration',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ] else ...[
          Text(
            _collegeController.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _sessionController.text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSkills() {
    return _isEditing
        ? TextFormField(
      controller: _skillsController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Skills',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: 'Add your skills (comma separated)...',
      ),
    )
        : Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _skillsController.text.split(',').map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            skill.trim(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjects() {
    return _isEditing
        ? TextFormField(
      controller: _projectsController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Projects',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: 'Add your projects...',
      ),
    )
        : Text(
      _projectsController.text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }

  Widget _buildAchievements() {
    return _isEditing
        ? TextFormField(
      controller: _achievementsController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Achievements',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: 'Add your achievements...',
      ),
    )
        : Text(
      _achievementsController.text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        _handleSave();
      }
      _isEditing = !_isEditing;
    });
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProfile = ProfileData(
        name: _nameController.text,
        email: _emailController.text,
        college: _collegeController.text,
        collegeSession: _sessionController.text,
        qualification: _qualificationController.text,
        jobProfile: _jobProfileController.text,
        skills: _skillsController.text,
        experience: _experienceController.text.split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList(),
        achievements: _achievementsController.text.split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList(),
        projects: _projectsController.text.split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList(),
        resumeUrl: widget.initialData.resumeUrl,
        profileImageUrl: widget.initialData.profileImageUrl,
        companyLikesCount: widget.initialData.companyLikesCount,
      );

      context.read<ProfileBloc>().add(UpdateProfile(updatedProfile));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _collegeController.dispose();
    _sessionController.dispose();
    _qualificationController.dispose();
    _jobProfileController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _projectsController.dispose();
    _achievementsController.dispose();
    super.dispose();
  }
}