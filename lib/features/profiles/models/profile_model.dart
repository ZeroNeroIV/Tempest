/// Represents a puzzle profile (e.g. 3x3x3, 2x2x2, or dynamic custom).
class ProfileModel {
  final String id;
  final String name;
  final bool isBuiltin;
  final String iconKey;
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.isBuiltin,
    required this.iconKey,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isBuiltin': isBuiltin,
        'iconKey': iconKey,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        name: json['name'] as String,
        isBuiltin: json['isBuiltin'] as bool? ?? false,
        iconKey: json['iconKey'] as String? ?? 'cube',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
