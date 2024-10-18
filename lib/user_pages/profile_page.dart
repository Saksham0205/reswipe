import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileFormKey = GlobalKey<FormState>();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _jobProfileController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  String _resumeUrl = '';
  File? _resumeFile;
  String _profileImageUrl = '';
  File? _profileImageFile;
  bool _isLoading = false;
  bool _isImageLoading = false;
  int _companyLikesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadCompanyLikesCount();
  }
  void _loadCompanyLikesCount() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final likesSnapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        _companyLikesCount = likesSnapshot.docs.length;
      });
    } catch (e) {
      print('Error loading company likes count: $e');
    }
  }
  void _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _qualificationController.text = userData['qualification'] ?? '';
          _jobProfileController.text = userData['jobProfile'] ?? '';
          _skillsController.text = userData['skills'] ?? '';
          _resumeUrl = userData['resumeUrl'] ?? '';
          _profileImageUrl = userData['profileImageUrl'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        setState(() {
          _profileImageFile = File(result.files.single.path!);
          _isImageLoading = true;
        });

        String userId = FirebaseAuth.instance.currentUser!.uid;
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('$userId.jpg');

        await storageRef.putFile(_profileImageFile!);
        String downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          _profileImageUrl = downloadUrl;
          _isImageLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image uploaded successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isImageLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile image: $e')),
      );
    }
  }

  Future<void> _pickAndUploadResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _resumeFile = File(result.files.single.path!);
          _isLoading = true;
        });

        String userId = FirebaseAuth.instance.currentUser!.uid;
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('resumes')
            .child('$userId.pdf');

        await storageRef.putFile(_resumeFile!);
        String downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'resumeUrl': downloadUrl,
        });

        setState(() {
          _resumeUrl = downloadUrl;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume uploaded successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload resume: $e')),
      );
    }
  }

  void _updateProfile() async {
    if (_profileFormKey.currentState!.validate()) {
      _profileFormKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'qualification': _qualificationController.text,
          'jobProfile': _jobProfileController.text,
          'skills': _skillsController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Form(
          key: _profileFormKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _isImageLoading ? null : _pickAndUploadProfileImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : null,
                          child: _profileImageUrl.isEmpty
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                      ),
                      if (_isImageLoading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.favorite,
                  title: 'Company Likes',
                  value: '$_companyLikesCount',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _qualificationController,
                  labelText: 'Qualification',
                  icon: Icons.school,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _jobProfileController,
                  labelText: 'Job Profile',
                  icon: Icons.work,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _skillsController,
                  labelText: 'Skills (comma-separated)',
                  icon: Icons.star,
                ),
                const SizedBox(height: 20),
                _buildResumeSection(),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Update Profile',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 20, color: Colors.deepPurple)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
      ),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildResumeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resume', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _resumeUrl.isNotEmpty
            ? const Row(
          children: [
            Icon(Icons.description, color: Colors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Resume uploaded successfully', overflow: TextOverflow.ellipsis)),
          ],
        )
            : const Text('No resume uploaded'),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file,color: Colors.white),
          label: const Text('Upload Resume (PDF)',style: TextStyle(color: Colors.white),),
          onPressed: _isLoading ? null : _pickAndUploadResume,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}