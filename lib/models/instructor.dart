/// Instructor model for users with teaching role.
class Instructor {
  const Instructor({
    required this.id,
    required this.fullName,
    this.userId,
    this.email,
    this.avatarUrl,
    this.title,
    this.department,
  });

  final String id;
  final String? userId;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String? title;
  final String? department;

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      title: json['title'] as String?,
      department: json['department'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        'avatar_url': avatarUrl,
        'title': title,
        'department': department,
      };

  Instructor copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? title,
    String? department,
  }) {
    return Instructor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      title: title ?? this.title,
      department: department ?? this.department,
    );
  }

  @override
  String toString() => 'Instructor(id: $id, fullName: $fullName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Instructor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
