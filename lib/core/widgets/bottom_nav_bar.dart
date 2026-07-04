import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/todos/presentation/bloc/todo_bloc.dart';
import '../../features/todos/presentation/bloc/todo_event.dart';
import '../../features/locations/presentation/bloc/location_bloc.dart';
import '../../features/locations/presentation/bloc/location_event.dart';
import '../../features/sync/presentation/bloc/sync_bloc.dart';
import '../../features/sync/presentation/bloc/sync_event.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/profile_event.dart';
import '../constants/app_icon.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 4-tab Bottom Navigation Bar (Tasks, Locations, Sync, Profile).
class BottomNavBar extends StatelessWidget {
  final String currentPath;
  final StatefulNavigationShell? navigationShell;

  const BottomNavBar({
    super.key,
    required this.currentPath,
    this.navigationShell,
  });

  int _calculateSelectedIndex(String path) {
    if (navigationShell != null) {
      return navigationShell!.currentIndex;
    }
    if (path.startsWith(RouteNames.locations)) return 1;
    if (path.startsWith(RouteNames.sync)) return 2;
    if (path.startsWith(RouteNames.profile)) return 3;
    return 0; // Default to Home / Tasks
  }

  void _onItemTapped(BuildContext context, int index) {
    if (navigationShell != null) {
      navigationShell!.goBranch(
        index,
        initialLocation: index == navigationShell!.currentIndex,
      );
      _refreshTabSilently(context, index);
      return;
    }

    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.locations);
        break;
      case 2:
        context.go(RouteNames.sync);
        break;
      case 3:
        context.go(RouteNames.profile);
        break;
    }
    _refreshTabSilently(context, index);
  }

  void _refreshTabSilently(BuildContext context, int index) {
    try {
      switch (index) {
        case 0:
          context.read<TodoBloc?>()?.add(const LoadTodosEvent());
          break;
        case 1:
          context.read<LocationBloc?>()?.add(const LoadLocations());
          break;
        case 2:
          context.read<SyncBloc?>()?.add(const LoadSyncStatus());
          break;
        case 3:
          context.read<ProfileBloc?>()?.add(const RefreshProfile());
          break;
      }
    } catch (_) {
      // Ignore if Bloc is not available in tree
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedColor = isDark ? AppColors.navActiveDark : AppColors.navActiveLight;
    final unselectedColor = isDark ? AppColors.navInactiveDark : AppColors.navInactiveLight;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final selectedIndex = _calculateSelectedIndex(currentPath);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        selectedLabelStyle: AppTextStyles.navbar,
        unselectedLabelStyle: AppTextStyles.navbar,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(AppIcon.tasksInactive, width: 24, height: 24),
            activeIcon: Image.asset(AppIcon.tasksActive, width: 24, height: 24),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(AppIcon.locationInactive, width: 24, height: 24),
            activeIcon: Image.asset(AppIcon.locationActive, width: 24, height: 24),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(AppIcon.syncInactive, width: 24, height: 24),
            activeIcon: Image.asset(AppIcon.syncActive, width: 24, height: 24),
            label: 'Sync',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(AppIcon.profileInactive, width: 24, height: 24),
            activeIcon: Image.asset(AppIcon.profileActive, width: 24, height: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}