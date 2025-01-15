import 'package:flutter/foundation.dart';

class ProfileData {
  String name;
  String email;
  String college;
  String collegeSession;
  String qualification;
  String jobProfile;
  String skills;
  List<String> experience;
  List<String> achievements;
  List<String> projects;
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
      experience: [],
      achievements: [],
      projects: [],
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
      experience: _parseStringOrList(map['experience']),
      achievements: _parseStringOrList(map['achievements']),
      projects: _parseStringOrList(map['projects']),
      resumeUrl: map['resumeUrl'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      companyLikesCount: map['companyLikesCount'] ?? 0,
    );
  }

  // Helper method to parse either String or List input
  static List<String> _parseStringOrList(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      return value.split('\n').where((item) => item.trim().isNotEmpty).toList();
    }
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
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
      'experience': experience,  // Store as array
      'achievements': achievements,  // Store as array
      'projects': projects,  // Store as array
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
        listEquals(experience, other.experience) &&
        listEquals(achievements, other.achievements) &&
        listEquals(projects, other.projects) &&
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
    experience = List<String>.from(parsedData['experience'] ?? []);
    achievements = List<String>.from(parsedData['formattedAchievements'] ?? []);
    projects = List<String>.from(parsedData['projects'] ?? []);
  }

  // Utility methods for working with lists
  String getExperienceText() => experience.join('\n');
  String getAchievementsText() => achievements.join('\n');
  String getProjectsText() => projects.join('\n');

  void setExperienceFromText(String text) {
    experience = text.split('\n').where((item) => item.trim().isNotEmpty).toList();
  }

  void setAchievementsFromText(String text) {
    achievements = text.split('\n').where((item) => item.trim().isNotEmpty).toList();
  }

  void setProjectsFromText(String text) {
    projects = text.split('\n').where((item) => item.trim().isNotEmpty).toList();
  }
}