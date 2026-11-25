class AppUser {
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  const AppUser({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'createdAt': createdAt.toIso8601String(),
      };
}
