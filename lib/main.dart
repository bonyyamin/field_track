import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;

/// Application Entry Point.
/// Initialises Flutter bindings, loads environment variables,
/// configures dependency injection, then runs [FieldTrackApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env before anything reads dotenv.env
  await dotenv.load(fileName: '.env');

  // Initialize Dependency Injection
  await di.configureDependencies();

  // Run the application
  runApp(const FieldTrackApp());
}