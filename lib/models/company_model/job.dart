class Job {
  final String id;
  final String title;
  final String description;
  final List<String> responsibilities;
  final List<String> qualifications;
  final String salaryRange;
  final String location;
  final String employmentType;
  final String companyId;
  final String companyName;


  Job({
    this.id = '',
    required this.title,
    required this.description,
    required this.responsibilities,
    required this.qualifications,
    required this.salaryRange,
    required this.location,
    required this.employmentType,
    required this.companyId,
    required this.companyName,


  });

  factory Job.fromMap(Map<String, dynamic> data, String id) {
    return Job(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      responsibilities: List<String>.from(data['responsibilities'] ?? []),
      qualifications: List<String>.from(data['qualifications'] ?? []),
      salaryRange: data['salaryRange'] ?? '',
      location: data['location'] ?? '',
      employmentType: data['employmentType'] ?? '',
      companyId: data['companyId'] ?? '',
      companyName: data['companyName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'responsibilities': responsibilities,
      'qualifications': qualifications,
      'salaryRange': salaryRange,
      'location': location,
      'employmentType': employmentType,
      'companyId': companyId,
      'companyName': companyName,

    };
  }

  Job copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? responsibilities,
    List<String>? qualifications,
    String? salaryRange,
    String? location,
    String? employmentType,
    String? companyId,
    String? companyName,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      qualifications: qualifications ?? this.qualifications,
      salaryRange: salaryRange ?? this.salaryRange,
      location: location ?? this.location,
      employmentType: employmentType ?? this.employmentType,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,

    );
  }
}