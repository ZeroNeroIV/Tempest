/// Represents a user/cubist profile.
class UserModel {
  final String id;
  final String name;
  final int avatarColorValue;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.avatarColorValue,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarColorValue': avatarColorValue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarColorValue: json['avatarColorValue'] as int? ?? 0xFF93C572,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  UserModel copyWith({
    String? name,
    int? avatarColorValue,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      createdAt: createdAt,
    );
  }
}
