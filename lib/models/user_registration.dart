class UserRegistration {
  final String name;
  final String email;
  final String role;
  final String? companyName;
  final String? companyId;

  UserRegistration({
    required this.name,
    required this.email,
    required this.role,
    this.companyName,
    this.companyId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'isVerified': false,
      'emailVerified': false,
      if (companyName != null) 'companyName': companyName,
      if (companyId != null) 'companyId': companyId,
    };
  }

  factory UserRegistration.fromMap(Map<String, dynamic> map) {
    return UserRegistration(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      companyName: map['companyName'],
      companyId: map['companyId'],
    );
  }
}