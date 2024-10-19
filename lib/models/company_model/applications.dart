import 'package:cloud_firestore/cloud_firestore.dart';

import 'job.dart';

class Application {
  final String id;
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
  final String qualification;
  final String jobProfile;
  final String resumeUrl;
  final String status;
  final DateTime? timestamp;

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
    required this.qualification,
    required this.jobProfile,
    required this.resumeUrl,
    required this.status,
    this.timestamp,
  });

  // Create from Firestore
  factory Application.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Application(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      jobDescription: data['jobDescription'] ?? '',
      jobResponsibilities: List<String>.from(data['jobResponsibilities'] ?? []),
      jobQualifications: List<String>.from(data['jobQualifications'] ?? []),
      jobSalaryRange: data['jobSalaryRange'] ?? '',
      jobLocation: data['jobLocation'] ?? '',
      jobEmploymentType: data['jobEmploymentType'] ?? '',
      companyId: data['companyId'] ?? '',
      companyName: data['companyName'] ?? '',
      userId: data['userId'] ?? '',
      applicantName: data['applicantName'] ?? '',
      qualification: data['qualification'] ?? '',
      jobProfile: data['jobProfile'] ?? '',
      resumeUrl: data['resumeUrl'] ?? '',
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Map
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
      'qualification': qualification,
      'jobProfile': jobProfile,
      'resumeUrl': resumeUrl,
      'status': status,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
    };
  }

  // Create copy with new values
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
    String? qualification,
    String? jobProfile,
    String? resumeUrl,
    String? status,
    DateTime? timestamp,
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
      qualification: qualification ?? this.qualification,
      jobProfile: jobProfile ?? this.jobProfile,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Helper method to create Application from Job
  factory Application.fromJob({
    required Job job,
    required String userId,
    required String applicantName,
    required String qualification,
    required String jobProfile,
    required String resumeUrl,
    String status = 'pending',
  }) {
    return Application(
      id: '',  // This will be set by Firestore
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
      userId: userId,
      applicantName: applicantName,
      qualification: qualification,
      jobProfile: jobProfile,
      resumeUrl: resumeUrl,
      status: status,
    );
  }
}