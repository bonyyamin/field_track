import 'package:field_tracker/features/auth/entities/user_entity.dart';

/// Data model for the user JSON returned by `/me`, `/login`, `/register`.
///
/// Keeps `fromJson` / `toJson` in the data layer — domain [UserEntity] stays clean.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userMap = json.containsKey('user') && json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json.containsKey('data') && json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json);

    return UserModel(
      id: userMap['id'] as String? ?? userMap['_id'] as String? ?? '',
      email: userMap['email'] as String? ?? '',
      fullName: userMap['full_name'] as String? ??
          userMap['fullName'] as String? ??
          userMap['name'] as String? ??
          '',
      role: userMap['role'] as String? ?? 'field_user',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'role': role,
      };

  /// Convert from domain entity (for caching).
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        email: entity.email,
        fullName: entity.fullName,
        role: entity.role,
      );
}