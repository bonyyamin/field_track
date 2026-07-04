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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? json['_id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
        role: json['role'] as String? ?? 'field_user',
      );

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