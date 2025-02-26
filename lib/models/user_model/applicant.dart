import 'package:cloud_firestore/cloud_firestore.dart';

class Applicant {
  final String id;
  final String name;
  final String jobProfile;
  final String resumeUrl;
  final String profilePhotoUrl;
  final String college;
  final int companyLikesCount;

  Applicant({
    required this.id,
    required this.name,
    required this.jobProfile,
    required this.resumeUrl,
    required this.profilePhotoUrl,
    required this.college,
    required this.companyLikesCount,
  });

  factory Applicant.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Applicant(
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
      'college': college,
      'companyLikesCount': companyLikesCount,
    };
  }
}
