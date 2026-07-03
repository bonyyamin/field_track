import 'package:get_it/get_it.dart';

/// Global Service Locator instance
final sl = GetIt.instance;

/// Configures and registers all application dependencies.
Future<void> configureDependencies() async {
  // ── Core / Network / Storage ──
  // Register core services (e.g. Dio, SecureStorage, LocalDatabase, NetworkInfo)

  // ── Feature: Auth ──
  // Register Data Sources, Repositories, Use Cases, and Blocs

  // ── Feature: Locations & Geofence ──
  // Register Data Sources, Repositories, Use Cases, and Blocs

  // ── Feature: Todos & Sync ──
  // Register Data Sources, Repositories, Use Cases, and Blocs
}