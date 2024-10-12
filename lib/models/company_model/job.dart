class Job {
  final String id;
  final String title;
  final String description;
  final String companyId;

  Job({
    this.id = '',
    required this.title,
    required this.description,
    this.companyId = '',
  });

  factory Job.fromMap(Map<String, dynamic> data, String id) {
    return Job(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      companyId: data['companyId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'companyId': companyId,
    };
  }
}
