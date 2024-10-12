class Applicant {
  final String id;
  final String name;
  final String jobProfile;
  final String resumeUrl;
  final String profilePhotoUrl;

  Applicant({
    this.id = '',
    required this.name,
    required this.jobProfile,
    required this.resumeUrl,
    this.profilePhotoUrl="",
  });

  factory Applicant.fromMap(Map<String, dynamic> data, String id) {
    return Applicant(
      id: id,
      name: data['name'] ?? '',
      jobProfile: data['jobProfile'] ?? '',
      resumeUrl: data['resumeUrl'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'jobProfile': jobProfile,
      'resumeUrl': resumeUrl,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }
}