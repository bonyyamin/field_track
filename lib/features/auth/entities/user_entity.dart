import 'package:equatable/equatable.dart';

/// Pure domain entity — no JSON, no Flutter dependency.
/// Represents an authenticated user in the domain layer.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, fullName, role];
}