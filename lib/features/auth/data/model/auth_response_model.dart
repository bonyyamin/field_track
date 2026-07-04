import 'package:field_tracker/features/auth/data/model/user_model.dart';

/// Represents the full response body from `/auth/login` and `/auth/register`.
///
/// ```json
/// {
///   "access_token": "...",
///   "refresh_token": "...",
///   "user": { "id": "...", "email": "...", "full_name": "...", "role": "..." }
/// }
/// ```
class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        accessToken: json['access_token'] as String? ?? '',
        refreshToken: json['refresh_token'] as String? ?? '',
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user': user.toJson(),
      };
}