import 'package:cloud_firestore/cloud_firestore.dart';

class Applications {
  final String id;
  final String name;
  final String jobProfile;
  final String resumeUrl;
  final String profilePhotoUrl;
  final String college; // New college field
  final int companyLikesCount;

  Applications({
    required this.id,
    required this.name,
    required this.jobProfile,
    required this.resumeUrl,
    required this.profilePhotoUrl,
    required this.college, // Initialize college field
    required this.companyLikesCount,
  });

  factory Applications.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Applications(
      id: doc.id,
      name: data['name'] ?? '',
      jobProfile: data['jobProfile'] ?? '',
      resumeUrl: data['resumeUrl'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] ?? '',
      college: data['college'] ?? '', // Parse college field
      companyLikesCount: data['companyLikesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'jobProfile': jobProfile,
      'resumeUrl': resumeUrl,
      'profilePhotoUrl': profilePhotoUrl,
      'college': college, // Add college to the map
      'companyLikesCount': companyLikesCount,
    };
  }
}
