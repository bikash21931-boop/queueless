class AppUser {
  final String id;
  final String email;
  final String name;

  AppUser({required this.id, required this.email, required this.name});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['user_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': id, 'email': email, 'name': name};
  }
}
