import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_tracker/core/di/injection_container.dart';
import 'package:field_tracker/core/router/app_router.dart';
import 'package:field_tracker/core/theme/app_theme.dart';
import 'package:field_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:field_tracker/features/settings/presentation/cubit/settings_state.dart';

/// Root Application Widget for FieldTrack.
/// Uses [MaterialApp.router] with [GoRouter] for navigation,
/// and configures light + dark themes from [AppTheme].
class FieldTrackApp extends StatelessWidget {
  const FieldTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => sl<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'FieldTrack',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}