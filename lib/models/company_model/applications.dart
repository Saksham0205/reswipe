import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String id;
  final String jobId;
  final String jobTitle;
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
      userId: userId ?? this.userId,
      applicantName: applicantName ?? this.applicantName,
      qualification: qualification ?? this.qualification,
      jobProfile: jobProfile ?? this.jobProfile,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}