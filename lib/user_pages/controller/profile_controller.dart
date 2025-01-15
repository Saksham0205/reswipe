import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/profile_data.dart';
import '../../services/resume_parser_service.dart';
import '../../services/storage_service.dart';


class ProfileController extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _resumeParser = ResumeParserService();
  final _storage = StorageService();

  bool _isLoading = false;
  bool _isImageLoading = false;
  bool _isParsingResume = false;
  bool _dataLoaded = false;
  bool _hasUnsavedChanges = false;

  // Local state controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final collegeController = TextEditingController();
  final collegeSessionController = TextEditingController();
  final qualificationController = TextEditingController();
  final jobProfileController = TextEditingController();
  final skillsController = TextEditingController();
  final experienceController = TextEditingController();
  final achievementsController = TextEditingController();
  final projectsController = TextEditingController();

  late ProfileData _profileData;
  late ProfileData _localProfileData;

  // Getters remain the same
  bool get isLoading => _isLoading;
  bool get isImageLoading => _isImageLoading;
  bool get isParsingResume => _isParsingResume;
  bool get dataLoaded => _dataLoaded;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  ProfileData get profileData => _localProfileData;

  ProfileController() {
    _profileData = ProfileData.empty();
    _localProfileData = ProfileData.empty();
    _setupControllerListeners();
  }

  void _setupControllerListeners() {
    void updateLocal() {
      _localProfileData = ProfileData(
        name: nameController.text,
        email: emailController.text,
        college: collegeController.text,
        collegeSession: collegeSessionController.text,
        qualification: qualificationController.text,
        jobProfile: jobProfileController.text,
        skills: skillsController.text,
        experience: _parseTextToList(experienceController.text),
        achievements: _parseTextToList(achievementsController.text),
        projects: _parseTextToList(projectsController.text),
        resumeUrl: _localProfileData.resumeUrl,
        profileImageUrl: _localProfileData.profileImageUrl,
        companyLikesCount: _localProfileData.companyLikesCount,
      );
      _hasUnsavedChanges = !_profileData.equals(_localProfileData);
      notifyListeners();
    }

    nameController.addListener(updateLocal);
    emailController.addListener(updateLocal);
    collegeController.addListener(updateLocal);
    collegeSessionController.addListener(updateLocal);
    qualificationController.addListener(updateLocal);
    jobProfileController.addListener(updateLocal);
    skillsController.addListener(updateLocal);
    experienceController.addListener(updateLocal);
    achievementsController.addListener(updateLocal);
    projectsController.addListener(updateLocal);
  }

  // Helper method to parse text to list
  List<String> _parseTextToList(String text) {
    return text.split('\n').where((item) => item.trim().isNotEmpty).toList();
  }

  // Helper method to join list to text
  String _joinListToText(List<String> list) {
    return list.join('\n');
  }

  Future<void> loadUserProfile() async {
    if (_dataLoaded) return;

    _setLoading(true);
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        _profileData = ProfileData.fromMap(userDoc.data()!);
        _localProfileData = ProfileData.fromMap(userDoc.data()!);

        // Update controllers without triggering listeners
        nameController.text = _profileData.name;
        emailController.text = _profileData.email;
        collegeController.text = _profileData.college;
        collegeSessionController.text = _profileData.collegeSession;
        qualificationController.text = _profileData.qualification;
        jobProfileController.text = _profileData.jobProfile;
        skillsController.text = _profileData.skills;
        experienceController.text = _joinListToText(_profileData.experience);
        achievementsController.text = _joinListToText(_profileData.achievements);
        projectsController.text = _joinListToText(_profileData.projects);

        _dataLoaded = true;
        _hasUnsavedChanges = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  void discardChanges() {
    nameController.text = _profileData.name;
    emailController.text = _profileData.email;
    collegeController.text = _profileData.college;
    collegeSessionController.text = _profileData.collegeSession;
    qualificationController.text = _profileData.qualification;
    jobProfileController.text = _profileData.jobProfile;
    skillsController.text = _profileData.skills;
    experienceController.text = _joinListToText(_profileData.experience);
    achievementsController.text = _joinListToText(_profileData.achievements);
    projectsController.text = _joinListToText(_profileData.projects);

    _localProfileData = _profileData;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  // Methods for directly manipulating lists
  void addExperience(String experience) {
    _localProfileData.experience.add(experience);
    experienceController.text = _joinListToText(_localProfileData.experience);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void addAchievement(String achievement) {
    _localProfileData.achievements.add(achievement);
    achievementsController.text = _joinListToText(_localProfileData.achievements);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void addProject(String project) {
    _localProfileData.projects.add(project);
    projectsController.text = _joinListToText(_localProfileData.projects);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void removeExperience(int index) {
    _localProfileData.experience.removeAt(index);
    experienceController.text = _joinListToText(_localProfileData.experience);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void removeAchievement(int index) {
    _localProfileData.achievements.removeAt(index);
    achievementsController.text = _joinListToText(_localProfileData.achievements);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void removeProject(int index) {
    _localProfileData.projects.removeAt(index);
    projectsController.text = _joinListToText(_localProfileData.projects);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  Future<void> saveChanges(BuildContext context) async {
    if (!_hasUnsavedChanges) return;

    _setLoading(true);
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(_localProfileData.toMap());

      _profileData = _localProfileData;
      _hasUnsavedChanges = false;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_data', json.encode(_profileData.toMap()));
  }


  // Refresh profile
  Future<void> refreshProfile() async {
    _dataLoaded = false;
    await loadUserProfile();
  }

  // Update profile
  Future<void> updateProfile(BuildContext? context, {bool showSnackBar = true}) async {
    if (context == null && showSnackBar) return;

    _setLoading(true);
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(_profileData.toMap());

      _hasUnsavedChanges = false;
      await _saveLocalProfile();

      if (showSnackBar && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (showSnackBar && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      _setLoading(false);
    }
  }
  // Upload profile image
  Future<void> uploadProfileImage(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null) return;

      _setImageLoading(true);
      final downloadUrl = await _storage.uploadProfileImage(
        File(result.files.single.path!),
        _auth.currentUser!.uid,
      );

      _profileData.profileImageUrl = downloadUrl;
      await updateProfile(context, showSnackBar: true);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      _setImageLoading(false);
    }
  }

  // Upload and parse resume
  Future<void> uploadAndParseResume(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null) return;

      _setParsingResume(true);
      final file = File(result.files.single.path!);

      // Upload resume
      final downloadUrl = await _storage.uploadResume(
        file,
        _auth.currentUser!.uid,
      );
      _profileData.resumeUrl = downloadUrl;

      // Parse resume
      final resumeText = await _resumeParser.extractTextFromPDF(file);
      final parsedData = await _resumeParser.parseResumeWithGemini(resumeText);

      // Update profile data with parsed information
      _profileData.updateFromParsedData(parsedData);
      _hasUnsavedChanges = true;
      await _saveLocalProfile();
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume parsed successfully! Click Save Changes to update your profile.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process resume: $e')),
        );
      }
    } finally {
      _setParsingResume(false);
    }
  }
  // Share profile
  Future<void> shareProfile(BuildContext context) async {
    final profileUrl = 'https://reswipe.app/profile/${_auth.currentUser!.uid}';
    await Share.share(
      'Check out my professional profile on Reswipe: $profileUrl',
      subject: 'My Reswipe Profile',
    );
  }



  // State management helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setImageLoading(bool value) {
    _isImageLoading = value;
    notifyListeners();
  }

  void _setParsingResume(bool value) {
    _isParsingResume = value;
    notifyListeners();
  }
  void updateLocalField(String field, dynamic value) {
    switch (field) {
      case 'qualification':
        _localProfileData.qualification = value;
        break;
      case 'jobProfile':
        _localProfileData.jobProfile = value;
        break;
      case 'experience':
        if (value is List<String>) {
          _localProfileData.experience = value;
          experienceController.text = _joinListToText(value);
        }
        break;
      case 'achievements':
        if (value is List<String>) {
          _localProfileData.achievements = value;
          achievementsController.text = _joinListToText(value);
        }
        break;
      case 'projects':
        if (value is List<String>) {
          _localProfileData.projects = value;
          projectsController.text = _joinListToText(value);
        }
        break;
    }
    _hasUnsavedChanges = true;
    _saveLocalProfile();
    notifyListeners();
  }

}