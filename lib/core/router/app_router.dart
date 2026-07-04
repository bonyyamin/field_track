import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:field_tracker/core/di/injection_container.dart';
import 'package:field_tracker/core/widgets/app_scaffold.dart';
import 'package:field_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:field_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:field_tracker/features/auth/presentation/pages/register_page.dart';
import 'package:field_tracker/features/locations/domain/entities/location_entity.dart';
import 'package:field_tracker/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_tracker/features/locations/presentation/pages/add_location_page.dart';
import 'package:field_tracker/features/locations/presentation/pages/edit_location_page.dart';
import 'package:field_tracker/features/locations/presentation/pages/locations_list_page.dart';
import 'package:field_tracker/features/splash/presentation/splash_page.dart';
import 'route_names.dart';

import 'package:field_tracker/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:field_tracker/features/todos/presentation/pages/todo_list_page.dart';
import 'package:field_tracker/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:field_tracker/features/sync/presentation/bloc/sync_event.dart';
import 'package:field_tracker/features/sync/presentation/pages/sync_page.dart';
import 'package:field_tracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:field_tracker/features/profile/presentation/bloc/profile_event.dart';
import 'package:field_tracker/features/profile/presentation/pages/profile_page.dart';

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
          builder: (context, state) => BlocProvider(
            create: (_) => sl<TodoBloc>(),
            child: const TodoListPage(),
          ),
        ),
        GoRoute(
          path: RouteNames.locations,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<LocationBloc>(),
            child: const LocationsListPage(),
          ),
        ),
        GoRoute(
          path: RouteNames.sync,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<SyncBloc>()..add(const LoadSyncStatus()),
            child: const SyncPage(),
          ),
        ),
        GoRoute(
          path: RouteNames.profile,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<ProfileBloc>()..add(const LoadProfile()),
            child: const ProfilePage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: RouteNames.addLocation,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<LocationBloc>(),
        child: const AddLocationPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.editLocation,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final location = state.extra is LocationEntity
            ? state.extra as LocationEntity
            : LocationEntity(
                id: id,
                locationName: 'Location',
                latitude: 0,
                longitude: 0,
                radiusM: 100,
              );
        return BlocProvider(
          create: (_) => sl<LocationBloc>(),
          child: EditLocationPage(location: location),
        );
      },
    ),
  ],
);