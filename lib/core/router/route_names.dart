/// Route path and name constants for FieldTrack navigation.
abstract final class RouteNames {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String locations = '/locations';
  static const String addLocation = '/locations/new';
  static const String editLocation = '/locations/:id/edit';
  static const String sync = '/sync';
  static const String profile = '/profile';

  /// Returns the formatted path for editing a location by ID.
  static String editLocationPath(String id) => '/locations/$id/edit';
}
