import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:field_tracker/core/router/route_names.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/core/widgets/app_button.dart';
import 'package:field_tracker/core/widgets/error_view.dart';
import 'package:field_tracker/core/widgets/loading_indicator.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/stat_chip.dart';

/// Main Profile Page displaying user details, stats, account menu, and sign out options.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showSignOutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign out',
          style: AppTextStyles.headingMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 14.5,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.errorDark : AppColors.errorLight,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProfileBloc>().add(const SignOutRequested());
            },
            child: Text(
              'Sign out',
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: errorColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is ProfileSignedOut) {
              context.go(RouteNames.login);
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial || state is ProfileSigningOut) {
              return const LoadingIndicator(message: 'Loading profile...');
            }

            if (state is ProfileError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context.read<ProfileBloc>().add(const LoadProfile()),
              );
            }

            if (state is ProfileLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(const RefreshProfile());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Screen Title Header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, top: 4),
                        child: Text(
                          'Profile',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: textColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Profile User Card Header
                      ProfileHeader(user: state.user),
                      const SizedBox(height: 16),

                      // Quick Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: StatChip(
                              value: '${state.stats.completedTasks}/${state.stats.totalTasks}',
                              label: 'Tasks done today',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: StatChip(
                              value: '${state.stats.activeLocationsCount}',
                              label: 'Active locations',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Account Settings Menu Card
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            ProfileMenuTile(
                              icon: Icons.person_outline_rounded,
                              label: 'Edit profile',
                              onTap: () => _showComingSoonSnackBar(context, 'Edit profile'),
                            ),
                            ProfileMenuTile(
                              icon: Icons.notifications_none_rounded,
                              label: 'Notifications',
                              onTap: () => _showComingSoonSnackBar(context, 'Notifications'),
                            ),
                            ProfileMenuTile(
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              onTap: () => _showComingSoonSnackBar(context, 'Settings'),
                            ),
                            ProfileMenuTile(
                              icon: Icons.help_outline_rounded,
                              label: 'Help & support',
                              onTap: () => _showComingSoonSnackBar(context, 'Help & support'),
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign Out Button
                      AppButton.outline(
                        label: 'Sign out',
                        icon: Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: errorColor,
                        ),
                        textColor: errorColor,
                        backgroundColor: Colors.transparent,
                        onPressed: () => _showSignOutDialog(context),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}