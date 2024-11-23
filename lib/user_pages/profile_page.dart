import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _collegeSessionController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _jobProfileController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _projectsController = TextEditingController();

  String _resumeUrl = '';
  File? _resumeFile;
  String _profileImageUrl = '';
  File? _profileImageFile;
  bool _isLoading = false;
  bool _isImageLoading = false;
  bool _isParsingResume = false;
  int _companyLikesCount = 0;
  bool _dataLoaded = false;

  Map<String, dynamic> _currentUserData = {};

  final _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyAB243NYKs2a6cXRPt6etv1KhOdfEJou0E',
  );

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadCompanyLikesCount();
    _addTextControllerListeners();
  }

  @override
  void dispose() {
    // Remove listeners when disposing
    _removeTextControllerListeners();
    _nameController.dispose();
    _emailController.dispose();
    _qualificationController.dispose();
    _jobProfileController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _achievementsController.dispose();
    _projectsController.dispose();
    super.dispose();
  }

  void _addTextControllerListeners() {
    _nameController.addListener(_onTextFieldChanged);
    _emailController.addListener(_onTextFieldChanged);
    _qualificationController.addListener(_onTextFieldChanged);
    _jobProfileController.addListener(_onTextFieldChanged);
    _skillsController.addListener(_onTextFieldChanged);
    _experienceController.addListener(_onTextFieldChanged);
    _achievementsController.addListener(_onTextFieldChanged);
    _projectsController.addListener(_onTextFieldChanged);
  }

  void _removeTextControllerListeners() {
    _nameController.removeListener(_onTextFieldChanged);
    _emailController.removeListener(_onTextFieldChanged);
    _qualificationController.removeListener(_onTextFieldChanged);
    _jobProfileController.removeListener(_onTextFieldChanged);
    _skillsController.removeListener(_onTextFieldChanged);
    _experienceController.removeListener(_onTextFieldChanged);
    _achievementsController.removeListener(_onTextFieldChanged);
    _projectsController.removeListener(_onTextFieldChanged);
  }

// Auto-save when text fields change
  void _onTextFieldChanged() {
    if (_dataLoaded) { // Only save if initial data has been loaded
      _debounceUpdate();
    }
  }

  Timer? _debounceTimer;

  void _debounceUpdate() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _updateProfile(showSnackBar: false);
    });
  }

  Future<String> _extractTextFromPDF(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      String text = '';
      PdfTextExtractor extractor = PdfTextExtractor(document);

      for (int i = 0; i < document.pages.count; i++) {
        text += await extractor.extractText(startPageIndex: i);
      }

      document.dispose();

      if (text
          .trim()
          .isEmpty) {
        throw Exception('No text could be extracted from the PDF');
      }

      return text;
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  Future<void> _parseResumeWithGemini(String resumeText) async {
    setState(() {
      _isParsingResume = true;
    });

    try {
      final prompt = Content.text('''
You are a specialized resume parser. Your task is to extract specific information from the provided resume text and return it in a strict JSON format. Follow these rules:

1. Only return valid JSON, no additional text or explanations
2. Use an empty string "" for missing fields
3. Use empty arrays [] for missing list items
4. Maintain the exact field names specified
5. For arrays, each item should be a single string
6. Preserve bullet points or numbers in achievements if they exist
7. Remove any special characters that could break JSON parsing
8. Extract college session in format YYYY-YYYY (e.g. 2022-2026)

Parse the following resume and return only this JSON structure:
{
  "fullName": "string (full name of the candidate)",
  "email": "string (email address if found)",
  "college": "string (name of the college/university if found)",
  "collegeSession": "string (college session in YYYY-YYYY format)",
  "education": "string (highest education qualification)",
  "jobProfile": "string (current or most recent job title)",
  "skills": ["skill1", "skill2", "skill3"],
  "experience": [
    "position1: company1 - duration1 - responsibilities1",
    "position2: company2 - duration2 - responsibilities2"
  ],
  "formattedAchievements": [
    "- achievement1",
    "1. achievement2"
  ],
  "projects": [
    "project1: description1",
    "project2: description2"
  ]
}

Resume text to parse:
${resumeText.trim()}
''');

      final response = await _retryGenerateContent(prompt);
      String? jsonString = response.text;
      jsonString = _cleanJsonString(jsonString);

      try {
        final Map<String, dynamic> parsedData = json.decode(jsonString);
        final sanitizedData = _sanitizeResumeData(parsedData);

        setState(() {
          _nameController.text = sanitizedData['fullName'];
          _emailController.text = sanitizedData['email'];
          _collegeController.text = sanitizedData['college'] ?? '';
          _collegeSessionController.text = sanitizedData['collegeSession'] ?? '';
          _qualificationController.text = sanitizedData['education'];
          _jobProfileController.text = sanitizedData['jobProfile'];
          _skillsController.text = sanitizedData['skills'].join(', ');
          _experienceController.text = sanitizedData['experience'].join('\n');
          _achievementsController.text = sanitizedData['formattedAchievements'].join('\n');
          _projectsController.text = sanitizedData['projects'].join('\n');
        });

        String userId = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'resumeUrl': _resumeUrl,
          'name': _nameController.text,
          'email': _emailController.text,
          'college': _collegeController.text,
          'collegeSession': _collegeSessionController.text,
          'qualification': _qualificationController.text,
          'jobProfile': _jobProfileController.text,
          'skills': _skillsController.text,
          'experience': _experienceController.text,
          'achievements': _achievementsController.text,
          'projects': _projectsController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume parsed and saved successfully!')),
        );
      } catch (jsonError) {
        throw Exception('Invalid JSON format: $jsonError\nResponse: $jsonString');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to parse resume: $e')),
      );
    } finally {
      setState(() {
        _isParsingResume = false;
      });
    }
  }
  Map<String, dynamic> _sanitizeResumeData(Map<String, dynamic> data) {
    return {
      'fullName': (data['fullName'] as String?) ?? '',
      'email': (data['email'] as String?) ?? '',
      'college': (data['college'] as String?) ?? '',
      'collegeSession': (data['collegeSession'] as String?) ?? '',
      'education': (data['education'] as String?) ?? '',
      'jobProfile': (data['jobProfile'] as String?) ?? '',
      'skills': (data['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      'experience': (data['experience'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      'formattedAchievements': (data['formattedAchievements'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      'projects': (data['projects'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    };
  }


  String _cleanJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      throw Exception('Empty response from Gemini');
    }

    // Remove any text before the first {
    int startIndex = jsonString.indexOf('{');
    int endIndex = jsonString.lastIndexOf('}');

    if (startIndex == -1 || endIndex == -1) {
      throw Exception('Invalid JSON structure');
    }

    return jsonString.substring(startIndex, endIndex + 1);
  }


  Future<GenerateContentResponse> _retryGenerateContent(Content prompt,
      {int maxAttempts = 3}) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await _model.generateContent([prompt]);
      } catch (e) {
        attempts++;
        if (attempts == maxAttempts) {
          throw Exception(
              'Failed to generate content after $maxAttempts attempts: $e');
        }
        await Future.delayed(
            Duration(seconds: attempts)); // Exponential backoff
      }
    }
    throw Exception('Unexpected error in retry logic');
  }

  void _loadCompanyLikesCount() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Get all applications for this user
      final applicationsSnapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .get();

      // Calculate total likes across all applications
      int totalLikes = 0;
      for (var doc in applicationsSnapshot.docs) {
        totalLikes += (doc.data()['companyLikesCount'] ?? 0) as int;
      }

      setState(() {
        _companyLikesCount = totalLikes;
      });
    } catch (e) {
    }
  }

  Widget _buildProfileStats() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                color: Colors.deepPurple,
                size: 20,
              ),
              SizedBox(width: 4),
              Text(
                'Company Likes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$_companyLikesCount',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const Text(
            'Total Likes',
            style: TextStyle(
              fontSize: 12,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  void _loadUserProfile() async {
    if (_dataLoaded) return; // Prevent multiple loads

    setState(() {
      _isLoading = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        _currentUserData = userDoc.data() as Map<String, dynamic>;

        // Update controllers with Firebase data
        setState(() {
          _nameController.text = _currentUserData['name'] ?? '';
          _emailController.text = _currentUserData['email'] ?? '';
          _collegeController.text = _currentUserData['college'] ?? '';
          _collegeSessionController.text = _currentUserData['collegeSession'] ?? '';
          _qualificationController.text =
              _currentUserData['qualification'] ?? '';
          _jobProfileController.text = _currentUserData['jobProfile'] ?? '';
          _skillsController.text = _currentUserData['skills'] ?? '';
          _experienceController.text = _currentUserData['experience'] ?? '';
          _achievementsController.text = _currentUserData['achievements'] ?? '';
          _projectsController.text = _currentUserData['projects'] ?? '';
          _resumeUrl = _currentUserData['resumeUrl'] ?? '';
          _profileImageUrl = _currentUserData['profileImageUrl'] ?? '';
          _dataLoaded = true;
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

        // Extract text from PDF
        final text = await _extractTextFromPDF(_resumeFile!);

        // Parse resume with Gemini
        await _parseResumeWithGemini(text);

        // Upload to Firebase
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
          'name': _nameController.text,
          'email': _emailController.text,
          'qualification': _qualificationController.text,
          'jobProfile': _jobProfileController.text,
          'skills': _skillsController.text,
          'experience': _experienceController.text,
          'achievements': _achievementsController.text,
          'projects': _projectsController.text,
        });

        setState(() {
          _resumeUrl = downloadUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process resume: $e')),
      );
    }
  }

  Future<void> _updateProfile({bool showSnackBar = true}) async {
    if (_profileFormKey.currentState!.validate()) {
      _profileFormKey.currentState!.save();

      Map<String, dynamic> newData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'college': _collegeController.text,
        'collegeSession': _collegeSessionController.text,
        'qualification': _qualificationController.text,
        'jobProfile': _jobProfileController.text,
        'skills': _skillsController.text,
        'experience': _experienceController.text,
        'achievements': _achievementsController.text,
        'projects': _projectsController.text,
        'resumeUrl': _resumeUrl,
        'profileImageUrl': _profileImageUrl,
      };

      // Check if data has actually changed
      bool hasChanges = false;
      newData.forEach((key, value) {
        if (_currentUserData[key] != value) {
          hasChanges = true;
        }
      });

      if (!hasChanges) return;

      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update(newData);

        _currentUserData = newData;

        if (showSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        if (showSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
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
        title: const Text('Professional Profile',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
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
                _buildHeaderSection(),
                const Divider(thickness: 2, height: 32),
                if (_isParsingResume)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Extracting data from resume...'),
                      ],
                    ),
                  ),
                _buildResumeUploadCard(),
                const SizedBox(height: 16),
                _buildProfessionalSection(),
                const SizedBox(height: 16),
                _buildSkillsAndAchievements(),
                const SizedBox(height: 24),
                _buildUpdateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Image Section
        Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: _isImageLoading ? null : _pickAndUploadProfileImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepPurple, width: 3),
                    ),
                    child: _isImageLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CircleAvatar(
                      radius: 58,
                      backgroundImage: _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : null,
                      child: _profileImageUrl.isEmpty
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileStats(),
          ],
        ),
        const SizedBox(width: 16),
        // Personal Information Fields
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                labelText: 'Full Name',
                icon: Icons.person,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _collegeController,
                labelText: 'College',
                icon: Icons.school,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _collegeSessionController,
                labelText: 'College Session (YYYY-YYYY)',
                icon: Icons.date_range,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) return 'This field is required';
              //     final pattern = RegExp(r'^\d{4}-\d{4}$');
              //     if (!pattern.hasMatch(value)) {
              //       return 'Please enter valid session format (YYYY-YYYY)';
              //     }
              //     return null;
              //   },
              // ),
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResumeUploadCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resume',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      _resumeUrl.isEmpty ? Icons.upload_file : Icons
                          .description,
                      size: 48,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _resumeUrl.isEmpty
                          ? 'Upload your resume (PDF)'
                          : 'Resume uploaded successfully',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickAndUploadResume,
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: Text(
                        _resumeUrl.isEmpty ? 'Select File' : 'Update Resume',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Professional Experience',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _qualificationController,
              labelText: 'Education',
              icon: Icons.school,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _jobProfileController,
              labelText: 'Current Job Profile',
              icon: Icons.work,
            ),
            const SizedBox(height: 16),
            _buildExperienceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    List<String> experiences = _experienceController.text.split('\n')
      ..removeWhere((e) => e.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.deepPurple),
              onPressed: () {
                // Add edit functionality here
                showDialog(
                  context: context,
                  builder: (context) => _buildExperienceEditDialog(),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        experiences.isEmpty
            ? const Center(
          child: Text(
            'No experience added yet',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: experiences.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  experiences[index],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkillsAndAchievements() {
    List<String> achievements = _achievementsController.text.split('\n')
      ..removeWhere((e) => e.isEmpty);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skills & Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _skillsController,
              labelText: 'Skills',
              icon: Icons.star,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                  onPressed: () {
                    // Add edit functionality here
                    showDialog(
                      context: context,
                      builder: (context) => _buildAchievementsEditDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            achievements.isEmpty
                ? const Center(
              child: Text(
                'No achievements added yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.deepPurple,
                      ),
                    ),
                    title: Text(
                      achievements[index],
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceEditDialog() {
    return AlertDialog(
      title: const Text('Edit Experience'),
      content: TextField(
        controller: _experienceController,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'Enter your experience (one per line)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _updateProfile(showSnackBar: false);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildAchievementsEditDialog() {
    return AlertDialog(
      title: const Text('Edit Achievements'),
      content: TextField(
        controller: _achievementsController,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'Enter your achievements (one per line)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _updateProfile(showSnackBar: false);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isMultiline = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: isMultiline ? null : 1,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildUpdateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _updateProfile(showSnackBar: true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(
            horizontal: 48,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Update Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


}