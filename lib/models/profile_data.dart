class ProfileData {
  String name;
  String email;
  String college;
  String collegeSession;
  String qualification;
  String jobProfile;
  String skills;
  String experience;
  String achievements;
  String projects;
  String resumeUrl;
  String profileImageUrl;
  int companyLikesCount;

  ProfileData({
    required this.name,
    required this.email,
    required this.college,
    required this.collegeSession,
    required this.qualification,
    required this.jobProfile,
    required this.skills,
    required this.experience,
    required this.achievements,
    required this.projects,
    required this.resumeUrl,
    required this.profileImageUrl,
    required this.companyLikesCount,
  });

  factory ProfileData.empty() {
    return ProfileData(
      name: '',
      email: '',
      college: '',
      collegeSession: '',
      qualification: '',
      jobProfile: '',
      skills: '',
      experience: '',
      achievements: '',
      projects: '',
      resumeUrl: '',
      profileImageUrl: '',
      companyLikesCount: 0,
    );
  }

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      college: map['college'] ?? '',
      collegeSession: map['collegeSession'] ?? '',
      qualification: map['qualification'] ?? '',
      jobProfile: map['jobProfile'] ?? '',
      skills: map['skills'] ?? '',
      experience: map['experience'] ?? '',
      achievements: map['achievements'] ?? '',
      projects: map['projects'] ?? '',
      resumeUrl: map['resumeUrl'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      companyLikesCount: map['companyLikesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'college': college,
      'collegeSession': collegeSession,
      'qualification': qualification,
      'jobProfile': jobProfile,
      'skills': skills,
      'experience': experience,
      'achievements': achievements,
      'projects': projects,
      'resumeUrl': resumeUrl,
      'profileImageUrl': profileImageUrl,
      'companyLikesCount': companyLikesCount,
    };
  }

  bool equals(ProfileData other) {
    return name == other.name &&
        email == other.email &&
        college == other.college &&
        collegeSession == other.collegeSession &&
        qualification == other.qualification &&
        jobProfile == other.jobProfile &&
        skills == other.skills &&
        experience == other.experience &&
        achievements == other.achievements &&
        projects == other.projects &&
        resumeUrl == other.resumeUrl &&
        profileImageUrl == other.profileImageUrl &&
        companyLikesCount == other.companyLikesCount;
  }

  void updateFromParsedData(Map<String, dynamic> parsedData) {
    name = parsedData['fullName'] ?? name;
    email = parsedData['email'] ?? email;
    college = parsedData['college'] ?? college;
    collegeSession = parsedData['collegeSession'] ?? collegeSession;
    qualification = parsedData['education'] ?? qualification;
    jobProfile = parsedData['jobProfile'] ?? jobProfile;
    skills = (parsedData['skills'] as List<String>).join(', ');
    experience = (parsedData['experience'] as List<String>).join('\n');
    achievements = (parsedData['formattedAchievements'] as List<String>).join('\n');
    projects = (parsedData['projects'] as List<String>).join('\n');
  }
}