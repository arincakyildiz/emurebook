class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? department;
  final String? studentId;
  final String? phone;
  final String role;
  final List<String> favoriteBooks;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.department,
    this.studentId,
    this.phone,
    required this.role,
    required this.favoriteBooks,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> favorites = [];
    if (json['favoriteBooks'] != null) {
      if (json['favoriteBooks'] is List) {
        favorites = (json['favoriteBooks'] as List)
            .map((item) => item is String ? item : item['_id'].toString())
            .toList()
            .cast<String>();
      }
    }

    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      department: json['department'],
      studentId: json['studentId'],
      phone: json['phone'],
      role: json['role'] ?? 'user',
      favoriteBooks: favorites,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'department': department,
      'studentId': studentId,
      'phone': phone,
      'role': role,
      'favoriteBooks': favoriteBooks,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
