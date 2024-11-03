import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String id;
  // Job related fields
  final String jobId;
  final String jobTitle;
  final String jobDescription;
  final List<String> jobResponsibilities;
  final List<String> jobQualifications;
  final String jobSalaryRange;
  final String jobLocation;
  final String jobEmploymentType;
  final String companyId;
  final String companyName;
  final String userId;
  final String applicantName;
  final String email;
  final String qualification;
  final String jobProfile;
  final List<String> skills;
  final List<String> experience;
  final List<String> achievements;
  final List<String> projects;
  final String resumeUrl;
  final String profileImageUrl;
  final String status;
  final DateTime? timestamp;
  final int companyLikesCount;

  Application({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.jobDescription,
    required this.jobResponsibilities,
    required this.jobQualifications,
    required this.jobSalaryRange,
    required this.jobLocation,
    required this.jobEmploymentType,
    required this.companyId,
    required this.companyName,
    required this.userId,
    required this.applicantName,
    required this.email,
    required this.qualification,
    required this.jobProfile,
    required this.skills,
    required this.experience,
    required this.achievements,
    required this.projects,
    required this.resumeUrl,
    required this.profileImageUrl,
    required this.status,
    this.timestamp,
    this.companyLikesCount = 0,
  });

  factory Application.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Application(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      jobDescription: data['jobDescription'] ?? '',
      jobResponsibilities: _convertToStringList(data['jobResponsibilities']),
      jobQualifications: _convertToStringList(data['jobQualifications']),
      jobSalaryRange: data['jobSalaryRange'] ?? '',
      jobLocation: data['jobLocation'] ?? '',
      jobEmploymentType: data['jobEmploymentType'] ?? '',
      companyId: data['companyId'] ?? '',
      companyName: data['companyName'] ?? '',
      userId: data['userId'] ?? '',
      applicantName: data['applicantName'] ?? '',
      email: data['email'] ?? '',
      qualification: data['qualification'] ?? '',
      jobProfile: data['jobProfile'] ?? '',
      skills: _convertToStringList(data['skills']),
      experience: _convertToStringList(data['experience']),
      achievements: _convertToStringList(data['achievements']),
      projects: _convertToStringList(data['projects']),
      resumeUrl: data['resumeUrl'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      companyLikesCount: data['companyLikesCount'] ?? 0,
    );
  }

  // Updated helper method to handle various data types more robustly
  static List<String> _convertToStringList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value is String) {
      if (value.isEmpty) return [];
      // Handle comma-separated strings
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    // Handle Map case
    if (value is Map) {
      return value.values.map((e) => e.toString()).toList();
    }

    // If it's a single non-list value, return it as a single-item list
    return [value.toString()];
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'jobDescription': jobDescription,
      'jobResponsibilities': jobResponsibilities,
      'jobQualifications': jobQualifications,
      'jobSalaryRange': jobSalaryRange,
      'jobLocation': jobLocation,
      'jobEmploymentType': jobEmploymentType,
      'companyId': companyId,
      'companyName': companyName,
      'userId': userId,
      'applicantName': applicantName,
      'email': email,
      'qualification': qualification,
      'jobProfile': jobProfile,
      'skills': skills,
      'experience': experience,
      'achievements': achievements,
      'projects': projects,
      'resumeUrl': resumeUrl,
      'profileImageUrl': profileImageUrl,
      'status': status,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
      'companyLikesCount': companyLikesCount,
    };
  }

  Application copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? jobDescription,
    List<String>? jobResponsibilities,
    List<String>? jobQualifications,
    String? jobSalaryRange,
    String? jobLocation,
    String? jobEmploymentType,
    String? companyId,
    String? companyName,
    String? userId,
    String? applicantName,
    String? email,
    String? qualification,
    String? jobProfile,
    List<String>? skills,
    List<String>? experience,
    List<String>? achievements,
    List<String>? projects,
    String? resumeUrl,
    String? profileImageUrl,
    String? status,
    DateTime? timestamp,
    int? companyLikesCount,
  }) {
    return Application(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      jobDescription: jobDescription ?? this.jobDescription,
      jobResponsibilities: jobResponsibilities ?? this.jobResponsibilities,
      jobQualifications: jobQualifications ?? this.jobQualifications,
      jobSalaryRange: jobSalaryRange ?? this.jobSalaryRange,
      jobLocation: jobLocation ?? this.jobLocation,
      jobEmploymentType: jobEmploymentType ?? this.jobEmploymentType,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      userId: userId ?? this.userId,
      applicantName: applicantName ?? this.applicantName,
      email: email ?? this.email,
      qualification: qualification ?? this.qualification,
      jobProfile: jobProfile ?? this.jobProfile,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      achievements: achievements ?? this.achievements,
      projects: projects ?? this.projects,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      companyLikesCount: companyLikesCount ?? this.companyLikesCount,
    );
  }
}