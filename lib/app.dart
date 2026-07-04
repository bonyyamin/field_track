import 'package:flutter/material.dart';
import 'package:field_tracker/core/router/app_router.dart';
import 'package:field_tracker/core/theme/app_theme.dart';

/// Root Application Widget for FieldTrack.
/// Uses [MaterialApp.router] with [GoRouter] for navigation,
/// and configures light + dark themes from [AppTheme].
class FieldTrackApp extends StatelessWidget {
  const FieldTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FieldTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}