class AppUser {
  final int id;
  final String name;
  final String email;
  final String roleName;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.roleName,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      roleName: (json['role'] as Map<String, dynamic>)['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
