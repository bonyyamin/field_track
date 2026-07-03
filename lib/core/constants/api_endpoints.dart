/// Single source of truth for API endpoint path strings.
abstract final class ApiEndpoints {
  // Base configuration
  static const String baseUrl = 'https://api.fieldtrack.app';
  static const String apiVersion = '/api/v1';

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refresh = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';

  // User profile
  static const String me = '$apiVersion/me';

  // Locations endpoints
  static const String locations = '$apiVersion/locations';
  static String locationById(String id) => '$apiVersion/locations/$id';

  // Todos / Tasks endpoints
  static const String todos = '$apiVersion/todos';
  static String todoById(String id) => '$apiVersion/todos/$id';
  static const String todoSync = '$apiVersion/todos/sync';
}