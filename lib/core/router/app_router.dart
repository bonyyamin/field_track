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
import 'package:field_tracker/features/todos/presentation/bloc/todo_event.dart';
import 'package:field_tracker/features/todos/presentation/pages/todo_list_page.dart';
import 'package:field_tracker/features/locations/presentation/bloc/location_event.dart';
import 'package:field_tracker/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:field_tracker/features/sync/presentation/bloc/sync_event.dart';
import 'package:field_tracker/features/sync/presentation/pages/sync_page.dart';
import 'package:field_tracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:field_tracker/features/profile/presentation/bloc/profile_event.dart';
import 'package:field_tracker/features/profile/presentation/pages/profile_page.dart';
import 'package:field_tracker/features/profile/presentation/pages/notifications_page.dart';
import 'package:field_tracker/features/profile/presentation/pages/settings_page.dart';
import 'package:field_tracker/features/profile/presentation/pages/help_support_page.dart';

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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<TodoBloc>()..add(const LoadTodosEvent())),
          BlocProvider(create: (_) => sl<LocationBloc>()..add(const LoadLocations())),
          BlocProvider(create: (_) => sl<SyncBloc>()..add(const LoadSyncStatus())),
          BlocProvider(create: (_) => sl<ProfileBloc>()..add(const LoadProfile())),
        ],
        child: AppScaffold(
          currentPath: state.matchedLocation,
          navigationShell: navigationShell,
          child: navigationShell,
        ),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (context, state) => const TodoListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.locations,
              builder: (context, state) => const LocationsListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.sync,
              builder: (context, state) => const SyncPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
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
    GoRoute(
      path: RouteNames.notifications,
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: RouteNames.helpSupport,
      builder: (context, state) => const HelpSupportPage(),
    ),
  ],
);