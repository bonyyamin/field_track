import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;

/// Application Entry Point.
/// Initializes Flutter bindings, dependency injection, and runs [FieldTrackApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  await di.configureDependencies();

  // Run the application
  runApp(const FieldTrackApp());
}