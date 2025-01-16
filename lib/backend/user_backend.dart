// user_backend.dart
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/company_model/applications.dart';
import '../models/company_model/job.dart';
import '../models/profile_data.dart';
import '../services/storage_service.dart';
import '../services/resume_parser_service.dart';

class UserBackend {
  static final UserBackend _instance = UserBackend._internal();
  factory UserBackend() => _instance;
  UserBackend._internal();

  final StorageService _storageService = StorageService();
  final ResumeParserService _resumeParserService = ResumeParserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentUserId;
  ProfileData? _profileData;
  List<Job>? _cachedJobs;
  Map<String, Map<String, dynamic>> _cachedCompanyDetails = {};
  DateTime? _lastJobsFetch;
  DateTime? _lastCompanyDetailsFetch;

  // Stream controllers
  final _jobsController = StreamController<List<Job>>.broadcast();
  final _applicationsController = StreamController<List<Application>>.broadcast();

  // Getters
  ProfileData? get profileData => _profileData;
  List<Job> get jobs => _cachedJobs ?? [];
  Stream<List<Job>> get jobsStream => _jobsController.stream;
  Stream<List<Application>> get applicationsStream => _applicationsController.stream;

  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    await Future.wait([
      _loadUserProfile(),
      _loadJobs(),
      _loadCompanyDetails(),
    ]);
  }

  Future<void> _loadUserProfile() async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .get();

      if (docSnapshot.exists) {
        _profileData = ProfileData.fromMap(docSnapshot.data()!);
      } else {
        _profileData = ProfileData.empty();
        await _firestore
            .collection('users')
            .doc(_currentUserId)
            .set(_profileData!.toMap());
      }
    } catch (e) {
      print('Error loading profile: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<void> _loadJobs() async {
    if (_shouldRefreshCache(_lastJobsFetch)) {
      try {
        QuerySnapshot querySnapshot = await _firestore.collection('jobs').get();
        _cachedJobs = querySnapshot.docs
            .map((doc) => Job.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        _lastJobsFetch = DateTime.now();
        _jobsController.add(_cachedJobs!);
      } catch (e) {
        print('Error loading jobs: $e');
        throw Exception('Failed to load jobs: $e');
      }
    }
  }

  Future<void> _loadCompanyDetails() async {
    if (_shouldRefreshCache(_lastCompanyDetailsFetch)) {
      try {
        Set<String> companyIds = _cachedJobs?.map((job) => job.companyId).toSet() ?? {};

        for (String companyId in companyIds) {
          DocumentSnapshot companyDoc = await _firestore
              .collection('applications')
              .doc(companyId)
              .get();

          if (companyDoc.exists) {
            _cachedCompanyDetails[companyId] = {
              'companyName': companyDoc.get('companyName') ?? 'Unknown Company',
              'logoUrl': companyDoc.get('logoUrl') ?? '',
            };
          }
        }
        _lastCompanyDetailsFetch = DateTime.now();
      } catch (e) {
        print('Error loading company details: $e');
        throw Exception('Failed to load company details: $e');
      }
    }
  }

  bool _shouldRefreshCache(DateTime? lastFetch) {
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch).inMinutes >= 5;
  }

  String getCompanyName(String companyId) {
    return _cachedCompanyDetails[companyId]?['companyName'] ?? 'Unknown Company';
  }

  String getCompanyLogo(String companyId) {
    return _cachedCompanyDetails[companyId]?['logoUrl'] ?? '';
  }

  Future<List<Job>> getFilteredJobs(String filter) async {
    await _loadJobs();

    if (filter.toLowerCase() == 'all') {
      return _cachedJobs ?? [];
    }

    return _cachedJobs
        ?.where((job) => job.employmentType.toLowerCase() == filter.toLowerCase())
        .toList() ?? [];
  }

  Future<void> applyForJob(Job job) async {
    if (_currentUserId == null) throw Exception('User not initialized');

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      String? resumeUrl = userData['resumeUrl'];
      if (resumeUrl == null || resumeUrl.isEmpty) {
        throw Exception('Please upload your resume before applying');
      }

      List<String> safeListFromDynamic(dynamic value) {
        if (value == null) return [];
        if (value is List) return value.map((e) => e.toString()).toList();
        if (value is String) return [value];
        return [];
      }

      Application application = Application(
        id: '',
        jobId: job.id,
        jobTitle: job.title,
        jobDescription: job.description,
        jobResponsibilities: job.responsibilities,
        jobQualifications: job.qualifications,
        jobSalaryRange: job.salaryRange,
        jobLocation: job.location,
        jobEmploymentType: job.employmentType,
        companyId: job.companyId,
        companyName: getCompanyName(job.companyId),
        userId: _currentUserId!,
        applicantName: userData['name']?.toString() ?? 'Unknown',
        email: userData['email']?.toString() ?? '',
        qualification: userData['qualification']?.toString() ?? '',
        jobProfile: userData['jobProfile']?.toString() ?? '',
        skills: safeListFromDynamic(userData['skills']),
        experience: safeListFromDynamic(userData['experience']),
        college: userData['college']?.toString() ?? '',
        achievements: safeListFromDynamic(userData['achievements']),
        projects: safeListFromDynamic(userData['projects']),
        resumeUrl: resumeUrl,
        profileImageUrl: userData['profileImageUrl']?.toString() ?? '',
        status: 'pending',
        timestamp: DateTime.now(),
        companyLikesCount: 0,
      );

      await _firestore
          .collection('applications')
          .add(application.toMap());

    } catch (e) {
      print('Application error: $e');
      throw Exception(e.toString());
    }
  }

  Future<void> uploadAndParseResume(File resumeFile) async {
    if (_currentUserId == null) throw Exception('User not initialized');

    try {
      // Upload resume to Firebase Storage
      final resumeUrl = await _storageService.uploadResume(resumeFile, _currentUserId!);

      // Extract text from PDF
      final resumeText = await _resumeParserService.extractTextFromPDF(resumeFile);

      // Parse resume text with Gemini
      final parsedData = await _resumeParserService.parseResumeWithGemini(resumeText);

      // Update profile data
      _profileData?.updateFromParsedData(parsedData);
      _profileData?.resumeUrl = resumeUrl;

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .update(_profileData!.toMap());
    } catch (e) {
      print('Error processing resume: $e');
      throw Exception('Failed to process resume: $e');
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    if (_currentUserId == null) throw Exception('User not initialized');

    try {
      final imageUrl = await _storageService.uploadProfileImage(imageFile, _currentUserId!);
      _profileData?.profileImageUrl = imageUrl;

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .update({'profileImageUrl': imageUrl});
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<void> updateProfile(ProfileData updatedProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .update(updatedProfile.toMap());
      _profileData = updatedProfile;
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }


  bool _shouldRefreshJobsCache() {
    if (_cachedJobs == null || _lastJobsFetch == null) return true;

    // Refresh cache if it's older than 5 minutes
    final cacheAge = DateTime.now().difference(_lastJobsFetch!);
    return cacheAge.inMinutes >= 5;
  }


  @override
  void dispose() {
    _jobsController.close();
    _applicationsController.close();
  }
}


// Events
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}
class UpdateProfile extends ProfileEvent {
  final ProfileData profileData;
  UpdateProfile(this.profileData);
}
class UploadResume extends ProfileEvent {
  final File file;
  UploadResume(this.file);
}
class UploadProfileImage extends ProfileEvent {
  final File file;
  UploadProfileImage(this.file);
}

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final ProfileData profile;
  ProfileLoaded(this.profile);
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserBackend userBackend;

  ProfileBloc({required this.userBackend}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadResume>(_onUploadResume);
    on<UploadProfileImage>(_onUploadProfileImage);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());
      final profile = userBackend.profileData;
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileError('Profile not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());
      await userBackend.updateProfile(event.profileData);
      emit(ProfileLoaded(event.profileData));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUploadResume(UploadResume event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());
      await userBackend.uploadAndParseResume(event.file);
      final updatedProfile = userBackend.profileData;
      if (updatedProfile != null) {
        emit(ProfileLoaded(updatedProfile));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUploadProfileImage(UploadProfileImage event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());
      await userBackend.uploadProfileImage(event.file);
      final updatedProfile = userBackend.profileData;
      if (updatedProfile != null) {
        emit(ProfileLoaded(updatedProfile));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}