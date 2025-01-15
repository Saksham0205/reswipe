import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../backend/user_backend.dart';
import '../models/profile_data.dart';

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

  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final file = File(image.path);
        context.read<ProfileBloc>().add(UploadProfileImage(file));
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
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
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: _toggleEdit,
                ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.blue),
                  onPressed: _handleSave,
                ),
            ],
          ),
          body: Stack(
            children: [
              _buildProfileContent(),
              if (state is ProfileLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
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
            _buildCoverAndProfile(),
            const SizedBox(height: 8),
            _buildBasicInfo(),
            const SizedBox(height: 8),
            _buildAboutSection(),
            const SizedBox(height: 8),
            _buildExperienceSection(),
            const SizedBox(height: 8),
            _buildEducationSection(),
            const SizedBox(height: 8),
            _buildSkillsSection(),
            const SizedBox(height: 8),
            _buildProjectsSection(),
            const SizedBox(height: 8),
            _buildAchievementsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverAndProfile() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditing)
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        )
                      else
                        Text(
                          _nameController.text,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (_isEditing)
                        TextFormField(
                          controller: _jobProfileController,
                          decoration: const InputDecoration(
                            labelText: 'Headline',
                            border: OutlineInputBorder(),
                          ),
                        )
                      else
                        Text(
                          _jobProfileController.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _pickAndUploadResume(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Resume'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    VoidCallback? onEdit,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isEditing && onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                  ),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return _buildSectionCard(
      title: 'Contact Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            title: _isEditing
                ? TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            )
                : Text(_emailController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return _buildSectionCard(
      title: 'About',
      child: _isEditing
          ? TextFormField(
        controller: _qualificationController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Write a summary about yourself...',
          border: OutlineInputBorder(),
        ),
      )
          : Text(_qualificationController.text),
    );
  }

  Widget _buildExperienceSection() {
    return _buildSectionCard(
      title: 'Experience',
      child: _isEditing
          ? TextFormField(
        controller: _experienceController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Add your work experience...',
          border: OutlineInputBorder(),
        ),
      )
          : Text(_experienceController.text),
    );
  }

  Widget _buildEducationSection() {
    return _buildSectionCard(
      title: 'Education',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing) ...[
            TextFormField(
              controller: _collegeController,
              decoration: const InputDecoration(
                labelText: 'Institution',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _sessionController,
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            Text(
              _collegeController.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_sessionController.text),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return _buildSectionCard(
      title: 'Skills',
      child: _isEditing
          ? TextFormField(
        controller: _skillsController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Add your skills (comma separated)...',
          border: OutlineInputBorder(),
        ),
      )
          : Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _skillsController.text
            .split(',')
            .map((skill) => Chip(
          label: Text(skill.trim()),
          backgroundColor: Colors.blue[50],
        ))
            .toList(),
      ),
    );
  }

  Widget _buildProjectsSection() {
    return _buildSectionCard(
      title: 'Projects',
      child: _isEditing
          ? TextFormField(
        controller: _projectsController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Add your projects...',
          border: OutlineInputBorder(),
        ),
      )
          : Text(_projectsController.text),
    );
  }

  Widget _buildAchievementsSection() {
    return _buildSectionCard(
      title: 'Achievements',
      child: _isEditing
          ? TextFormField(
        controller: _achievementsController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Add your achievements...',
          border: OutlineInputBorder(),
        ),
      )
          : Text(_achievementsController.text),
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