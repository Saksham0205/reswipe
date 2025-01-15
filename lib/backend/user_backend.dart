// user_backend.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  ProfileData? get profileData => _profileData;

  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    await _loadUserProfile();
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
        // Create new profile if it doesn't exist
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