import 'package:cloud_firestore/cloud_firestore.dart';

class Applications {
  final String id;
  final String name;
  final String jobProfile;
  final String resumeUrl;
  final String profilePhotoUrl;
  final int companyLikesCount;

  Applications({
    required this.id,
    required this.name,
    required this.jobProfile,
    required this.resumeUrl,
    required this.profilePhotoUrl,
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
      companyLikesCount: data['companyLikesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'jobProfile': jobProfile,
      'resumeUrl': resumeUrl,
      'profilePhotoUrl': profilePhotoUrl,
      'companyLikesCount': companyLikesCount,
    };
  }
}
