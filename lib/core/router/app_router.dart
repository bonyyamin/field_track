import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:field_tracker/core/di/injection_container.dart';
import 'package:field_tracker/core/widgets/app_scaffold.dart';
import 'package:field_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:field_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:field_tracker/features/auth/presentation/pages/register_page.dart';
import 'package:field_tracker/features/splash/presentation/splash_page.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Main Application Router using GoRouter.
final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const SplashPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const RegisterPage(),
      ),
    ),
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => AppScaffold(
        currentPath: state.matchedLocation,
        child: child,
      ),
      routes: [
        GoRoute(
          path: RouteNames.home,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Tasks Screen')),
          ),
        ),
        GoRoute(
          path: RouteNames.locations,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Locations Screen')),
          ),
        ),
        GoRoute(
          path: RouteNames.sync,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Sync Screen')),
          ),
        ),
        GoRoute(
          path: RouteNames.profile,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Profile Screen')),
          ),
        ),
      ],
    ),
    GoRoute(
      path: RouteNames.addLocation,
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Add Location Screen')),
      ),
    ),
    GoRoute(
      path: RouteNames.editLocation,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return Scaffold(
          body: Center(child: Text('Edit Location Screen ($id)')),
        );
      },
    ),
  ],
);