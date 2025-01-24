// user_backend.dart
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/company_model/applications.dart';
import '../models/company_model/job.dart';
import '../models/user_model/profile_data.dart';
import '../services/storage_service.dart';
import '../services/resume_parser_service.dart';

class UserBackend {
  static final UserBackend _instance = UserBackend._internal();
  factory UserBackend() => _instance;
  late final SharedPreferences _prefs;

  UserBackend._internal() {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }
  final StorageService _storageService = StorageService();
  final ResumeParserService _resumeParserService = ResumeParserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  ProfileData? _profileData;
  List<Job>? _cachedJobs;
  List<Application>? _cachedApplications;
  Map<String, Map<String, dynamic>> _cachedCompanyDetails = {};
  DateTime? _lastJobsFetch;
  DateTime? _lastApplicationsFetch;
  DateTime? _lastCompanyDetailsFetch;
  Set<String> _swipedJobIds = {};

  // Stream controllers with proper BehaviorSubject
  final _jobsController = BehaviorSubject<List<Job>>();
  final _applicationsController = BehaviorSubject<List<Application>>();
  StreamSubscription? _applicationsSubscription;

  // Getters
  ProfileData? get profileData => _profileData;
  List<Job> get jobs => _cachedJobs ?? [];
  List<Application> get applications => _cachedApplications ?? [];
  Stream<List<Application>> get applicationsStream => _applicationsController.stream;
  Stream<List<Job>> get jobsStream => _jobsController.stream;

  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    await _loadSwipedJobs(); // Load swiped jobs first
    await Future.wait([
      _loadUserProfile(),
      _loadJobs(),
      _loadCompanyDetails(),
    ]);
    _setupApplicationsListener();
  }

  // Add method to load swiped jobs from SharedPreferences
  Future<void> _loadSwipedJobs() async {
    final String key = 'swiped_jobs_${_currentUserId ?? "default"}';
    final List<String>? swipedJobs = _prefs.getStringList(key);
    if (swipedJobs != null) {
      _swipedJobIds = Set<String>.from(swipedJobs);
    }
  }

  // Add method to save swiped jobs to SharedPreferences
  Future<void> _saveSwipedJobs() async {
    final String key = 'swiped_jobs_${_currentUserId ?? "default"}';
    await _prefs.setStringList(key, _swipedJobIds.toList());
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
        // Get company IDs from both jobs and applications
        Set<String> companyIds = {};
        if (_cachedJobs != null) {
          companyIds.addAll(_cachedJobs!.map((job) => job.companyId));
        }
        if (_cachedApplications != null) {
          companyIds.addAll(_cachedApplications!.map((app) => app.companyId));
        }

        for (String companyId in companyIds) {
          DocumentSnapshot companyDoc = await _firestore
              .collection('companies')  // Make sure this is the correct collection
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
    await _loadSwipedJobs(); // Ensure we have the latest swiped jobs

    // Filter out swiped jobs first
    List<Job> availableJobs = _cachedJobs?.where((job) => !_swipedJobIds.contains(job.id)).toList() ?? [];

    if (filter.toLowerCase() == 'all') {
      return availableJobs;
    }

    return availableJobs
        .where((job) => job.employmentType.toLowerCase() == filter.toLowerCase())
        .toList();
  }

  Future<void> markJobAsSwiped(String jobId) async {
    _swipedJobIds.add(jobId);
    await _saveSwipedJobs();
  }

  // Modify clearSwipedJobs method to persist the change
  Future<void> clearSwipedJobs() async {
    _swipedJobIds.clear();
    await _saveSwipedJobs();
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

  // Update these methods in your UserBackend class

  void _setupApplicationsListener() {
    _applicationsSubscription?.cancel();

    _applicationsSubscription = _firestore
        .collection('applications')
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        try {
          _cachedApplications = snapshot.docs
              .map((doc) => Application.fromFirestore(doc))
              .toList();
          _lastApplicationsFetch = DateTime.now();
          _applicationsController.add(_cachedApplications!);
        } catch (e) {
          _applicationsController.addError('Failed to process applications: $e');
        }
      },
      onError: (error) {
        _applicationsController.addError('Error in applications stream: $error');
      },
    );
  }

  Future<List<Application>> getApplications() async {
    if (_shouldRefreshCache(_lastApplicationsFetch)) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('applications')
            .where('userId', isEqualTo: _currentUserId)
            .orderBy('timestamp', descending: true)
            .get();

        _cachedApplications = querySnapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList();
        _lastApplicationsFetch = DateTime.now();
        _applicationsController.add(_cachedApplications!);
      } catch (e) {
        print('Error loading applications: $e');
        throw Exception('Failed to load applications: $e');
      }
    }
    return _cachedApplications ?? [];
  }

  Future<void> applyForJob(Job job) async {
    if (_currentUserId == null) throw Exception('User not initialized');

    try {
      // Get user document
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Check for resume
      String? resumeUrl = userData['resumeUrl'];
      if (resumeUrl == null || resumeUrl.isEmpty) {
        throw Exception('Please upload your resume before applying');
      }

      // Helper function to safely convert to List<String>
      List<String> safeListFromDynamic(dynamic value) {
        if (value == null) return [];
        if (value is List) return value.map((e) => e.toString()).toList();
        if (value is String) return [value];
        return [];
      }

      // Create application object
      Application application = Application(
        id: '',  // Will be set by Firestore
        jobId: job.id,
        jobTitle: job.title,
        jobDescription: job.description,
        jobResponsibilities: job.responsibilities,
        jobQualifications: job.qualifications,
        jobSalaryRange: job.salaryRange,
        jobLocation: job.location,
        jobEmploymentType: job.employmentType,
        companyId: job.companyId,
        companyName: job.companyName,
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
        statusUpdatedAt: DateTime.now(),
        companyLikesCount: 0,
      );

      // Add to Firestore
      await _firestore
          .collection('applications')
          .add(application.toMap());

      // Update local cache
      _cachedApplications = [...(_cachedApplications ?? []), application];
      _applicationsController.add(_cachedApplications!);

    } catch (e) {
      print('Application error: $e');
      throw Exception(e.toString());
    }
  }


  List<Application> getCachedApplications() {
    return _cachedApplications ?? [];
  }


  @override
  void dispose() {
    _jobsController.close();
    _applicationsController.close();
    _applicationsSubscription?.cancel();
  }
}

class ApplicationsBloc extends Cubit<ApplicationsState> {
  final UserBackend _userBackend;
  StreamSubscription? _applicationsSubscription;

  ApplicationsBloc(this._userBackend) : super(ApplicationsInitial()) {
    _initializeBloc();
  }

  void _initializeBloc() {
    _applicationsSubscription = _userBackend.applicationsStream.listen(
          (applications) {
        emit(ApplicationsLoaded(applications));
      },
      onError: (error) {
        emit(ApplicationsError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() async {
    await _applicationsSubscription?.cancel();
    return super.close();
  }
}

// Applications State
abstract class ApplicationsState {}

class ApplicationsInitial extends ApplicationsState {}

class ApplicationsLoaded extends ApplicationsState {
  final List<Application> applications;
  ApplicationsLoaded(this.applications);
}

class ApplicationsError extends ApplicationsState {
  final String message;
  ApplicationsError(this.message);
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